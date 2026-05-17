import 'dart:convert';
import 'dart:ui' show VoidCallback;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:gql/language.dart' show parseString;
import 'package:pocketcrm/domain/models/company.dart';
import 'package:pocketcrm/domain/models/contact.dart';
import 'package:pocketcrm/domain/models/note.dart';
import 'package:pocketcrm/domain/models/task.dart';
import 'package:pocketcrm/domain/models/workspace_member.dart';
import 'package:pocketcrm/shared/widgets/phone_input_field.dart';
import 'package:pocketcrm/core/data/country_codes.dart';
import 'package:pocketcrm/domain/repositories/crm_repository.dart';
import 'package:pocketcrm/core/network/custom_http_client.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:pocketcrm/core/auth/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TwentyConnector implements CRMRepository {
  final GraphQLClient client;
  final AuthService? authService;
  final VoidCallback? onTokenRefreshed;
  String? _currentMemberId;

  /// Mutex for token refresh — prevents concurrent refresh attempts
  Future<bool>? _refreshFuture;

  TwentyConnector({required this.client, this.authService, this.onTokenRefreshed});

  /// Returns the current workspace member's ID, caching it for the session.
  /// Returns null for API key auth (show all tasks) — only filters for email auth.
  Future<String?> _getCurrentMemberId() async {
    if (_currentMemberId != null) return _currentMemberId;

    // Only filter by assignee for email/password auth.
    // API key users see all tasks.
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    final authMethod = await storage.read(key: 'auth_method') ?? 'api_key';
    if (authMethod != 'email') return null;

    const String query = r'''
      query Me {
        workspaceMembers(first: 1) {
          edges {
            node {
              id
            }
          }
        }
      }
    ''';
    final options = QueryOptions(
      document: parseString(query),
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final result = await _queryWithRefresh(options);
    final edges = result.data?['workspaceMembers']?['edges'] as List?;
    if (edges != null && edges.isNotEmpty) {
      _currentMemberId = edges.first['node']?['id'] as String?;
    }
    return _currentMemberId;
  }

  Future<QueryResult> _queryWithRefresh(QueryOptions options) async {
    // Proactively refresh if we know the token is expired
    if (authService != null && await authService!.isTokenExpired()) {
      await _tryRefresh();
    }

    QueryResult result = await client.query(options);

    if (result.hasException && _isUnauthenticated(result.exception!)) {
      final isRefreshed = await _tryRefresh();
      if (isRefreshed) {
        result = await client.query(options);
      }
    }
    return result;
  }

  Future<QueryResult> _mutateWithRefresh(MutationOptions options) async {
    // Proactively refresh if we know the token is expired
    if (authService != null && await authService!.isTokenExpired()) {
      await _tryRefresh();
    }

    QueryResult result = await client.mutate(options);

    if (result.hasException && _isUnauthenticated(result.exception!)) {
      final isRefreshed = await _tryRefresh();
      if (isRefreshed) {
        result = await client.mutate(options);
      }
    }
    return result;
  }

  bool _isUnauthenticated(OperationException exception) {
    // Check GraphQL error codes and messages
    if (exception.graphqlErrors.any((e) {
      final code = e.extensions?['code']?.toString().toUpperCase() ?? '';
      final msg = e.message.toLowerCase();
      return code == 'UNAUTHENTICATED' ||
          msg.contains('unauthenticated') ||
          msg.contains('token has expired') ||
          msg.contains('token expired') ||
          msg.contains('expired token') ||
          msg.contains('jwt expired') ||
          msg.contains('invalid token');
    })) {
      return true;
    }
    // Check link-level exceptions (HTTP 401)
    final linkException = exception.linkException;
    if (linkException is ServerException && linkException.parsedResponse?.response['status'] == 401) {
      return true;
    }
    // Fallback: check raw exception string
    final exStr = exception.toString().toLowerCase();
    if (exStr.contains('401') || 
        exStr.contains('unauthenticated') ||
        exStr.contains('token has expired') ||
        exStr.contains('token expired') ||
        exStr.contains('jwt expired')) {
      return true;
    }
    return false;
  }

  /// Attempts to refresh the auth token. Uses a mutex so only one refresh
  /// runs at a time — concurrent callers wait for the same result.
  Future<bool> _tryRefresh() async {
    if (authService == null) return false;

    // If a refresh is already in progress, wait for that one's result
    if (_refreshFuture != null) {
      return _refreshFuture!;
    }

    _refreshFuture = _doRefresh();
    try {
      return await _refreshFuture!;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<bool> _doRefresh() async {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    final authMethod = await storage.read(key: 'auth_method') ?? 'api_key';

    if (authMethod != 'email') return false; // API keys don't need refresh

    final isSuccess = await authService!.refreshAccessToken();
    if (isSuccess) {
      // Notify caller to invalidate any caches (e.g. StorageService in-memory cache)
      onTokenRefreshed?.call();
    }
    return isSuccess;
  }

  void _handleResultException(QueryResult result) {
    if (!result.hasException) return;

    final exception = result.exception!;
    final linkException = exception.linkException;

    // Log exception to Sentry (fire and forget)
    try {
      Sentry.captureException(
        exception,
        stackTrace: StackTrace.current,
        hint: Hint.withMap({'operation': result.context.toString()}),
      );
    } catch (_) {}

    // Check if this is an auth error that survived the refresh attempt
    if (_isUnauthenticated(exception)) {
      throw Exception('Token has expired.');
    }

    if (linkException != null) {
      final errorStr = linkException.toString();
      if (errorStr.contains('SocketException') ||
          errorStr.contains('NetworkError') ||
          errorStr.contains('Connection closed')) {
        throw Exception(
          'It seems there\'s no internet connection. Please check your settings.',
        );
      }
      if (errorStr.contains('Connection refused') ||
          errorStr.contains('404') ||
          errorStr.contains('Network unreachable')) {
        throw Exception(
          'The CRM endpoint is unreachable. Please verify the URL in settings.',
        );
      }
      if (errorStr.contains('TimeoutException')) {
        throw Exception(
          'The server took too long to respond. Please try again later.',
        );
      }
      throw Exception('Connection error: $errorStr');
    }

    if (exception.graphqlErrors.isNotEmpty) {
      final error = exception.graphqlErrors.first;
      final msg = error.message.toLowerCase();
      if (msg.contains('unauthorized') || msg.contains('forbidden')) {
        throw Exception(
          'Session expired or invalid token. Please reconnect in settings.',
        );
      }
      if (msg.contains('cannot be executed as a single request') ||
          msg.contains('query is too complex') ||
          msg.contains('complexity limit')) {
        throw Exception(
          'Your Twenty instance has restrictive query limits. '
          'Please update Twenty to the latest version, or contact your server administrator '
          'to increase the GraphQL query complexity limit.',
        );
      }
      throw Exception(error.message);
    }

    throw Exception(
      'An unexpected error occurred while communicating with the server.',
    );
  }

  static Future<bool> testConnection(String baseUrl, String apiToken) async {
    const String query = r'''
      query Me {
        workspaceMembers(first: 1) {
          edges {
            node {
              name { firstName lastName }
            }
          }
        }
      }
    ''';

    final customHttpClient = TimeoutHttpClient(
      timeoutDuration: const Duration(seconds: 30),
    );

    final tempLink = HttpLink(
      '$baseUrl/graphql',
      defaultHeaders: {'Authorization': 'Bearer $apiToken'},
      httpClient: customHttpClient,
    );

    final tempClient = GraphQLClient(
      link: tempLink,
      cache: GraphQLCache(),
      queryRequestTimeout: const Duration(seconds: 30),
    );

    final QueryResult result = await tempClient.query(
      QueryOptions(
        document: parseString(query),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      final exception = result.exception!;
      if (exception.graphqlErrors.isNotEmpty) {
        final error = exception.graphqlErrors.first;
        final msg = error.message.toLowerCase();

        if (msg.contains('unauthorized') || msg.contains('forbidden')) {
          throw Exception('Invalid API Token');
        }

        // If the server rejects the query due to complexity limits, it means
        // the URL and the Token are actually valid (auth succeeded!).
        // So we can safely consider the connection successful.
        if (msg.contains('cannot be executed as a single request') ||
            msg.contains('query is too complex') ||
            msg.contains('complexity limit')) {
          return true;
        }

        throw Exception(error.message);
      }

      if (exception.linkException != null) {
        final linkError = exception.linkException.toString();
        if (linkError.contains('404')) {
          throw Exception('URL not found. Verify your Instance URL.');
        }
        if (linkError.contains('Connection refused') ||
            linkError.contains('SocketException')) {
          throw Exception('Server unreachable. Check your internet or URL.');
        }
        throw Exception('Network error: $linkError');
      }

      throw Exception('Something went wrong: ${exception.toString()}');
    }

    final edges = result.data?['workspaceMembers']?['edges'] as List?;
    if (edges == null || edges.isEmpty) {
      throw Exception('Connected, but no access to workspace.');
    }

    return true;
  }

  @override
  Future<List<WorkspaceMember>> getWorkspaceMembers() async {
    const String query = r'''
      query GetWorkspaceMembers {
        workspaceMembers(first: 100) {
          edges {
            node {
              id
              name {
                firstName
                lastName
              }
            }
          }
        }
      }
    ''';
    final options = QueryOptions(
      document: parseString(query),
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final result = await _queryWithRefresh(options);
    _handleResultException(result);
    final edges = result.data?['workspaceMembers']?['edges'] as List?;
    if (edges == null) return [];
    return edges
        .map((e) => WorkspaceMember.fromTwenty(e['node'] as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<String> getCurrentUserName() async {
    const String query = r'''
      query Me {
        workspaceMembers(first: 1) {
          edges {
            node {
              name { firstName lastName }
            }
          }
        }
      }
    ''';
    final QueryOptions options = QueryOptions(document: parseString(query));
    final QueryResult result = await _queryWithRefresh(options);

    final edges = result.data?['workspaceMembers']?['edges'] as List?;
    if (edges == null || edges.isEmpty) return '';

    final name = edges.first['node']?['name'];
    if (name == null) return '';
    return '${name['firstName']} ${name['lastName']}'.trim();
  }

  @override
  Future<({List<Contact> contacts, String? endCursor, bool hasNextPage})>
  getContacts({String? search, int pageSize = 20, String? after}) async {
    const String query = r'''
      query GetPeople($filter: PersonFilterInput, $first: Int, $after: String) {
        people(filter: $filter, first: $first, after: $after, orderBy: { createdAt: DescNullsLast }) {
          edges {
            node {
              id
              name { firstName lastName }
              emails { primaryEmail }
              phones { primaryPhoneNumber primaryPhoneCallingCode }
              avatarUrl
              company { id name }
              createdAt
              updatedAt
            }
          }
          pageInfo { hasNextPage endCursor }
        }
      }
    ''';

    Map<String, dynamic>? filter;
    if (search != null && search.isNotEmpty) {
      filter = {
        'or': [
          {
            'name': {
              'firstName': {'ilike': '%$search%'},
            },
          },
          {
            'name': {
              'lastName': {'ilike': '%$search%'},
            },
          },
        ],
      };
    }

    final QueryOptions options = QueryOptions(
      document: parseString(query),
      variables: {
        'first': pageSize,
        if (filter != null) 'filter': filter,
        if (after != null) 'after': after,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await _queryWithRefresh(options);
    _handleResultException(result);

    final data = result.data?['people'];
    final edges = data?['edges'] as List? ?? [];
    final pageInfo = data?['pageInfo'] as Map<String, dynamic>? ?? {};

    final contacts = edges
        .map((e) => Contact.fromTwenty(e['node'] as Map<String, dynamic>))
        .toList();

    return (
      contacts: contacts,
      endCursor: pageInfo['endCursor'] as String?,
      hasNextPage: pageInfo['hasNextPage'] as bool? ?? false,
    );
  }

  @override
  Future<Contact> getContactById(String id) async {
    const String query = r'''
      query GetPersonById($id: UUID!) {
        people(filter: { id: { eq: $id } }) {
          edges {
            node {
              id
              name { firstName lastName }
              emails { primaryEmail additionalEmails }
              phones { primaryPhoneNumber primaryPhoneCallingCode additionalPhones }
              avatarUrl
              city
              jobTitle
              company { id name }
              createdAt
              updatedAt
            }
          }
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: parseString(query),
      variables: {'id': id},
    );

    final QueryResult result = await _queryWithRefresh(options);
    _handleResultException(result);

    final edges = result.data?['people']?['edges'] as List?;
    if (edges == null || edges.isEmpty) throw Exception('Contact not found');

    return Contact.fromTwenty(edges.first['node'] as Map<String, dynamic>);
  }

  @override
  Future<List<Contact>> getContactsByCompany(String companyId) async {
    const String query = r'''
      query GetCompanyPeople($filter: PersonFilterInput) {
        people(filter: $filter, orderBy: { createdAt: DescNullsLast }) {
          edges {
            node {
              id
              name { firstName lastName }
              emails { primaryEmail }
              phones { primaryPhoneNumber primaryPhoneCallingCode }
              avatarUrl
              company { id name }
              createdAt
              updatedAt
            }
          }
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: parseString(query),
      variables: {
        'filter': {
          'companyId': {'eq': companyId},
        },
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await _queryWithRefresh(options);
    _handleResultException(result);

    final edges = result.data?['people']?['edges'] as List?;
    if (edges == null) return [];

    return edges
        .map((e) => Contact.fromTwenty(e['node'] as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Contact>> getContactsByTask(String taskId) async {
    const String query = r'''
      query GetTaskTargets($filter: TaskTargetFilterInput) {
        taskTargets(filter: $filter) {
          edges {
            node {
              targetPerson {
                id
                name { firstName lastName }
                emails { primaryEmail }
                phones { primaryPhoneNumber primaryPhoneCallingCode }
                avatarUrl
                company { id name }
                createdAt
                updatedAt
              }
            }
          }
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: parseString(query),
      variables: {
        'filter': {
          'taskId': {'eq': taskId},
        },
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await _queryWithRefresh(options);
    _handleResultException(result);

    final edges = result.data?['taskTargets']?['edges'] as List?;
    if (edges == null) return [];

    return edges
        .where((e) => e['node']?['targetPerson'] != null)
        .map(
          (e) => Contact.fromTwenty(
            e['node']['targetPerson'] as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<Contact> createContact({
    required String firstName,
    required String lastName,
    String? email,
    String? phone,
  }) async {
    const String mutation = r'''
      mutation CreatePerson($input: PersonCreateInput!) {
        createPerson(data: $input) {
          id
          name { firstName lastName }
          emails { primaryEmail }
        }
      }
    ''';

    String? phoneCountryCode;
    if (phone != null) {
      final parsed = PhoneInputField.parseE164(phone);
      final match = countryCodes.where((c) => c.dialCode == parsed.$1).toList();
      if (match.isNotEmpty) {
        phoneCountryCode = match.first.isoCode;
      }
    }

    final input = {
      'name': {'firstName': firstName, 'lastName': lastName},
      if (email != null) 'emails': {'primaryEmail': email},
      if (phone != null)
        'phones': {
          'primaryPhoneNumber': phone,
          if (phoneCountryCode != null)
            'primaryPhoneCountryCode': phoneCountryCode,
        },
    };

    final MutationOptions options = MutationOptions(
      document: parseString(mutation),
      variables: {'input': input},
    );

    final QueryResult result = await _mutateWithRefresh(options);
    _handleResultException(result);

    return Contact.fromTwenty(
      result.data?['createPerson'] as Map<String, dynamic>,
    );
  }

  @override
  Future<Contact> updateContact(
    String id, {
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? companyId,
    bool clearCompany = false,
  }) async {
    const String mutation = r'''
      mutation UpdatePerson($id: UUID!, $input: PersonUpdateInput!) {
        updatePerson(id: $id, data: $input) {
          id
          name { firstName lastName }
          emails { primaryEmail }
          phones { primaryPhoneNumber primaryPhoneCallingCode }
          company { id name }
        }
      }
    ''';

    final input = <String, dynamic>{};
    if (firstName != null || lastName != null) {
      input['name'] = {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
      };
    }
    if (email != null) {
      input['emails'] = {'primaryEmail': email};
    }
    if (phone != null) {
      String? phoneCountryCode;
      final parsed = PhoneInputField.parseE164(phone);
      final match = countryCodes.where((c) => c.dialCode == parsed.$1).toList();
      if (match.isNotEmpty) {
        phoneCountryCode = match.first.isoCode;
      }

      input['phones'] = {
        'primaryPhoneNumber': phone,
        if (phoneCountryCode != null)
          'primaryPhoneCountryCode': phoneCountryCode,
      };
    }
    if (clearCompany) {
      input['companyId'] = null;
    } else if (companyId != null) {
      input['companyId'] = companyId;
    }

    final MutationOptions options = MutationOptions(
      document: parseString(mutation),
      variables: {'id': id, 'input': input},
    );

    final QueryResult result = await _mutateWithRefresh(options);
    _handleResultException(result);

    return Contact.fromTwenty(
      result.data?['updatePerson'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteContact(String id) async {
    const String mutation = r'''
      mutation DeletePerson($id: UUID!) {
        deletePerson(id: $id) { id }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: parseString(mutation),
      variables: {'id': id},
    );

    final QueryResult result = await _mutateWithRefresh(options);
    _handleResultException(result);
  }

  @override
  Future<Company> createCompany({
    required String name,
    String? domainName,
  }) async {
    const String mutation = r'''
      mutation CreateCompany($input: CompanyCreateInput!) {
        createCompany(data: $input) {
          id
          name
          domainName { primaryLinkUrl }
          createdAt
        }
      }
    ''';

    final input = <String, dynamic>{'name': name};
    if (domainName != null && domainName.isNotEmpty) {
      input['domainName'] = {'primaryLinkUrl': domainName};
    }

    final MutationOptions options = MutationOptions(
      document: parseString(mutation),
      variables: {'input': input},
    );

    final QueryResult result = await _mutateWithRefresh(options);
    _handleResultException(result);

    final data = result.data?['createCompany'];
    if (data == null) throw Exception('Failed to create company');

    return Company.fromTwenty(data as Map<String, dynamic>);
  }

  @override
  Future<Company> updateCompany(
    String id, {
    String? name,
    String? domainName,
  }) async {
    const String mutation = r'''
      mutation UpdateCompany($id: UUID!, $input: CompanyUpdateInput!) {
        updateCompany(id: $id, data: $input) {
          id
          name
          domainName { primaryLinkUrl }
          createdAt
        }
      }
    ''';

    final input = <String, dynamic>{};
    if (name != null) input['name'] = name;
    if (domainName != null) {
      // Support clearing domain by providing empty string
      input['domainName'] = domainName.isEmpty
          ? null
          : {'primaryLinkUrl': domainName};
    }

    final MutationOptions options = MutationOptions(
      document: parseString(mutation),
      variables: {'id': id, 'input': input},
    );

    final QueryResult result = await _mutateWithRefresh(options);
    _handleResultException(result);

    return Company.fromTwenty(
      result.data?['updateCompany'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteCompany(String id) async {
    const String mutation = r'''
      mutation DeleteCompany($id: UUID!) {
        deleteCompany(id: $id) { id }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: parseString(mutation),
      variables: {'id': id},
    );

    final QueryResult result = await _mutateWithRefresh(options);
    _handleResultException(result);
  }

  @override
  Future<List<Company>> getCompanies({String? search, int page = 1}) async {
    const String query = r'''
      query GetCompanies($filter: CompanyFilterInput, $first: Int) {
        companies(filter: $filter, first: $first, orderBy: { createdAt: DescNullsLast }) {
          edges {
            node {
              id
              name
              domainName { primaryLinkUrl }
              employees
              createdAt
            }
          }
        }
      }
    ''';

    Map<String, dynamic>? filter;
    if (search != null && search.isNotEmpty) {
      filter = {
        'or': [
          {
            'name': {'like': '%$search%'},
          },
          {
            'domainName': {
              'primaryLinkUrl': {'like': '%$search%'},
            },
          },
        ],
      };
    }

    final QueryOptions options = QueryOptions(
      document: parseString(query),
      variables: {'first': 20, if (filter != null) 'filter': filter},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await _queryWithRefresh(options);
    _handleResultException(result);

    final edges = result.data?['companies']?['edges'] as List?;
    if (edges == null) return [];

    return edges
        .map((e) => Company.fromTwenty(e['node'] as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Company> getCompanyById(String id) async {
    const String query = r'''
      query GetCompanyById($id: UUID!) {
        companies(filter: { id: { eq: $id } }) {
          edges {
            node {
              id
              name
              domainName { primaryLinkUrl }
              employees
              createdAt
            }
          }
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: parseString(query),
      variables: {'id': id},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await _queryWithRefresh(options);
    _handleResultException(result);

    final edges = result.data?['companies']?['edges'] as List?;
    if (edges == null || edges.isEmpty) throw Exception('Company not found');

    return Company.fromTwenty(edges.first['node'] as Map<String, dynamic>);
  }

  @override
  Future<List<Note>> getNotesByCompany(String companyId) async {
    const String query = r'''
      query GetNotesByCompany($companyId: UUID!) {
        noteTargets(filter: { targetCompanyId: { eq: $companyId } },
                    orderBy: { createdAt: DescNullsLast }) {
          edges {
            node {
              note { id bodyV2 { blocknote } createdAt updatedAt }
            }
          }
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: parseString(query),
      variables: {'companyId': companyId},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await _queryWithRefresh(options);
    _handleResultException(result);

    final edges = result.data?['noteTargets']?['edges'] as List?;
    if (edges == null) return [];

    return edges
        .map((e) {
          final node = e['node'];
          if (node == null || node['note'] == null) return null;
          return Note.fromTwenty(node['note'] as Map<String, dynamic>);
        })
        .where((e) => e != null)
        .cast<Note>()
        .toList();
  }

  @override
  Future<List<Note>> getNotesByContact(String contactId) async {
    const String query = r'''
      query GetNotesByPerson($personId: UUID!) {
        noteTargets(filter: { targetPersonId: { eq: $personId } },
                    orderBy: { createdAt: DescNullsLast }) {
          edges {
            node {
              note { id bodyV2 { blocknote } createdAt updatedAt }
            }
          }
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: parseString(query),
      variables: {'personId': contactId},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await _queryWithRefresh(options);
    _handleResultException(result);

    final edges = result.data?['noteTargets']?['edges'] as List?;
    if (edges == null) return [];

    return edges
        .map((e) {
          final node = e['node'];
          if (node == null || node['note'] == null) return null;
          return Note.fromTwenty(node['note'] as Map<String, dynamic>);
        })
        .where((e) => e != null)
        .cast<Note>()
        .toList();
  }

  @override
  Future<Note> createNote({
    required String contactId,
    required String body,
    DateTime? dueAt, // Kept in interface but ignored for GraphQL Note
  }) async {
    const String mutation = r'''
      mutation CreateNote($input: NoteCreateInput!) {
        createNote(data: $input) { id bodyV2 { blocknote } createdAt }
      }
    ''';

    final blockNodeJson = jsonEncode([
      {
        "type": "paragraph",
        "content": [
          {"type": "text", "text": body, "styles": {}},
        ],
      },
    ]);

    final input = <String, dynamic>{
      'bodyV2': {'blocknote': blockNodeJson},
    };

    final MutationOptions options = MutationOptions(
      document: parseString(mutation),
      variables: {'input': input},
    );

    final QueryResult result = await _mutateWithRefresh(options);
    _handleResultException(result);

    final data = result.data?['createNote'];
    final note = Note.fromTwenty(data as Map<String, dynamic>);

    const String targetMutation = r'''
      mutation CreateNoteTarget($input: NoteTargetCreateInput!) {
        createNoteTarget(data: $input) { id }
      }
    ''';
    final targetInput = {'noteId': note.id, 'targetPersonId': contactId};
    final MutationOptions targetOptions = MutationOptions(
      document: parseString(targetMutation),
      variables: {'input': targetInput},
    );
    final targetResult = await _mutateWithRefresh(targetOptions);
    if (targetResult.hasException) {
      print(
        'Warning: Failed to link note to contact: ${targetResult.exception}',
      );
    }

    return note;
  }

  @override
  Future<Note> updateNote(
    String id, {
    required String body,
    DateTime? dueAt, // Kept in interface but ignored for GraphQL Note
  }) async {
    const String mutation = r'''
      mutation UpdateNote($id: UUID!, $input: NoteUpdateInput!) {
        updateNote(id: $id, data: $input) { id bodyV2 { blocknote } createdAt }
      }
    ''';

    final blockNodeJson = jsonEncode([
      {
        "type": "paragraph",
        "content": [
          {"type": "text", "text": body, "styles": {}},
        ],
      },
    ]);

    final input = <String, dynamic>{
      'bodyV2': {'blocknote': blockNodeJson},
    };

    final MutationOptions options = MutationOptions(
      document: parseString(mutation),
      variables: {'id': id, 'input': input},
    );

    final QueryResult result = await _mutateWithRefresh(options);
    _handleResultException(result);

    return Note.fromTwenty(result.data?['updateNote'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteNote(String id) async {
    const String mutation = r'''
      mutation DeleteNote($id: UUID!) {
        deleteNote(id: $id) { id }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: parseString(mutation),
      variables: {'id': id},
    );

    final QueryResult result = await _mutateWithRefresh(options);
    _handleResultException(result);
  }

  @override
  Future<List<Task>> getOverdueTasks() async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final memberId = await _getCurrentMemberId();

    final conditions = [
      '{ dueAt: { lt: "${startOfToday.toIso8601String()}" } }',
      '{ status: { neq: DONE } }',
      if (memberId != null) '{ assigneeId: { eq: "$memberId" } }',
    ];

    final String query =
        '''
      query GetOverdueTasks {
        tasks(
          filter: {
            and: [
              ${conditions.join('\n              ')}
            ]
          }
          orderBy: { dueAt: AscNullsLast }
        ) {
          edges { node { 
            id title status dueAt 
            taskTargets { edges { node {
              targetPersonId targetPerson { id name { firstName lastName } }
              targetCompanyId targetCompany { id name }
              targetOpportunityId targetOpportunity { id name }
            } } }
          } }
        }
      }
    ''';

    final options = QueryOptions(
      document: parseString(query),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final result = await _queryWithRefresh(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final edges = result.data?['tasks']?['edges'] as List?;
    if (edges == null) return [];

    return edges
        .map((e) => Task.fromTwenty(e['node'] as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Task>> getTodayTasks() async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));
    final memberId = await _getCurrentMemberId();

    final conditions = [
      '{ dueAt: { gte: "${startOfToday.toIso8601String()}" } }',
      '{ dueAt: { lt: "${endOfToday.toIso8601String()}" } }',
      '{ status: { neq: DONE } }',
      if (memberId != null) '{ assigneeId: { eq: "$memberId" } }',
    ];

    final String query =
        '''
      query GetTodayTasks {
        tasks(
          filter: {
            and: [
              ${conditions.join('\n              ')}
            ]
          }
          orderBy: { dueAt: AscNullsLast }
        ) {
          edges { node { 
            id title status dueAt 
            taskTargets { edges { node {
              targetPersonId targetPerson { id name { firstName lastName } }
              targetCompanyId targetCompany { id name }
              targetOpportunityId targetOpportunity { id name }
            } } }
          } }
        }
      }
    ''';

    final options = QueryOptions(
      document: parseString(query),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final result = await _queryWithRefresh(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final edges = result.data?['tasks']?['edges'] as List?;
    if (edges == null) return [];

    return edges
        .map((e) => Task.fromTwenty(e['node'] as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Task>> getTomorrowTasks() async {
    final now = DateTime.now();
    final startOfTomorrow = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    final endOfTomorrow = startOfTomorrow.add(const Duration(days: 1));
    final memberId = await _getCurrentMemberId();

    final conditions = [
      '{ dueAt: { gte: "${startOfTomorrow.toIso8601String()}" } }',
      '{ dueAt: { lt: "${endOfTomorrow.toIso8601String()}" } }',
      '{ status: { neq: DONE } }',
      if (memberId != null) '{ assigneeId: { eq: "$memberId" } }',
    ];

    final String query =
        '''
      query GetTomorrowTasks {
        tasks(
          filter: {
            and: [
              ${conditions.join('\n              ')}
            ]
          }
          orderBy: { dueAt: AscNullsLast }
        ) {
          edges { node { 
            id title status dueAt 
            taskTargets { edges { node {
              targetPersonId targetPerson { id name { firstName lastName } }
              targetCompanyId targetCompany { id name }
              targetOpportunityId targetOpportunity { id name }
            } } }
          } }
        }
      }
    ''';

    final options = QueryOptions(
      document: parseString(query),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final result = await _queryWithRefresh(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final edges = result.data?['tasks']?['edges'] as List?;
    if (edges == null) return [];

    return edges
        .map((e) => Task.fromTwenty(e['node'] as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Contact>> getRecentContacts({int limit = 5}) async {
    const String query = r'''
      query GetRecentContacts($first: Int!) {
        people(
          first: $first
          orderBy: { updatedAt: DescNullsLast }
        ) {
          edges { node {
            id
            name { firstName lastName }
            avatarUrl
            emails { primaryEmail }
            company { name }
            updatedAt
          } }
        }
      }
    ''';

    final options = QueryOptions(
      document: parseString(query),
      variables: {'first': limit},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final result = await _queryWithRefresh(options);
    _handleResultException(result);

    final edges = result.data?['people']?['edges'] as List?;
    if (edges == null) return [];

    return edges
        .map((e) => Contact.fromTwenty(e['node'] as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Task>> getTasks({bool? completed}) async {
    const String query = r'''
      query GetTasks($filter: TaskFilterInput) {
        tasks(filter: $filter, orderBy: { dueAt: AscNullsLast }) {
          edges {
            node {
              id title bodyV2 { blocknote } status dueAt createdAt
              taskTargets { edges { node {
                targetPersonId targetPerson { id name { firstName lastName } }
                targetCompanyId targetCompany { id name }
                targetOpportunityId targetOpportunity { id name }
              } } }
            }
          }
        }
      }
    ''';

    final memberId = await _getCurrentMemberId();

    final List<Map<String, dynamic>> conditions = [];
    if (completed != null) {
      conditions.add({'status': {'eq': completed ? 'DONE' : 'TODO'}});
    }
    if (memberId != null) {
      conditions.add({'assigneeId': {'eq': memberId}});
    }

    Map<String, dynamic>? filter;
    if (conditions.isNotEmpty) {
      filter = conditions.length == 1
          ? conditions.first
          : {'and': conditions};
    }

    final QueryOptions options = QueryOptions(
      document: parseString(query),
      variables: {if (filter != null) 'filter': filter},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await _queryWithRefresh(options);
    _handleResultException(result);

    final edges = result.data?['tasks']?['edges'] as List?;
    if (edges == null) return [];

    return edges
        .map((e) => Task.fromTwenty(e['node'] as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Task> createTask({
    required String title,
    String? body,
    DateTime? dueAt,
    String? contactId,
    String? assigneeId,
  }) async {
    const String mutation = r'''
      mutation CreateTask($input: TaskCreateInput!) {
        createTask(data: $input) { id title status bodyV2 { blocknote } dueAt createdAt assigneeId }
      }
    ''';

    final input = <String, dynamic>{'title': title};
    
    // Assign automatically if not provided explicitly, but only for email auth (currentMemberId exists)
    final targetAssigneeId = assigneeId ?? await _getCurrentMemberId();
    if (targetAssigneeId != null) {
      input['assigneeId'] = targetAssigneeId;
    }
    if (body != null) {
      final blockNodeJson = jsonEncode([
        {
          "type": "paragraph",
          "content": [
            {"type": "text", "text": body, "styles": {}},
          ],
        },
      ]);
      input['bodyV2'] = {'blocknote': blockNodeJson};
    }
    if (dueAt != null) {
      final utcDueAt = dueAt.toUtc();
      input['dueAt'] = "${utcDueAt.toIso8601String().split('.')[0]}Z";
    }

    final MutationOptions options = MutationOptions(
      document: parseString(mutation),
      variables: {'input': input},
    );

    final QueryResult result = await _mutateWithRefresh(options);
    _handleResultException(result);

    if (contactId != null) {
      final taskId = result.data?['createTask']?['id'];
      if (taskId != null) {
        const String targetMutation = r'''
          mutation CreateTaskTarget($input: TaskTargetCreateInput!) {
            createTaskTarget(data: $input) { id }
          }
        ''';
        final targetInput = {'taskId': taskId, 'targetPersonId': contactId};
        final MutationOptions targetOptions = MutationOptions(
          document: parseString(targetMutation),
          variables: {'input': targetInput},
        );
        final targetResult = await _mutateWithRefresh(targetOptions);
        if (targetResult.hasException) {
          print(
            'Warning: Failed to link task to contact: ${targetResult.exception}',
          );
        }
      }
    }
    final data = result.data?['createTask'];

    return Task.fromTwenty(data);
  }

  @override
  Future<Task> updateTask(
    String id, {
    String? title,
    String? body,
    DateTime? dueAt,
    bool clearDueDate = false,
    bool? completed,
    String? assigneeId,
  }) async {
    const String mutation = r'''
      mutation UpdateTask($id: UUID!, $input: TaskUpdateInput!) {
        updateTask(id: $id, data: $input) { id title status bodyV2 { blocknote } dueAt createdAt assigneeId }
      }
    ''';

    final input = <String, dynamic>{};
    if (title != null) input['title'] = title;
    if (assigneeId != null) input['assigneeId'] = assigneeId;
    if (completed != null) {
      input['status'] = completed ? 'DONE' : 'TODO';
    }
    if (body != null) {
      final blockNodeJson = jsonEncode([
        {
          "type": "paragraph",
          "content": [
            {"type": "text", "text": body, "styles": {}},
          ],
        },
      ]);
      input['bodyV2'] = {'blocknote': blockNodeJson};
    }
    if (clearDueDate) {
      input['dueAt'] = null;
    } else if (dueAt != null) {
      final utcDueAt = dueAt.toUtc();
      input['dueAt'] = "${utcDueAt.toIso8601String().split('.')[0]}Z";
    }

    // In a real scenario we'd want to also be able to clear dueAt.
    // For now we just send what is provided.

    final MutationOptions options = MutationOptions(
      document: parseString(mutation),
      variables: {'id': id, 'input': input},
    );

    final QueryResult result = await _mutateWithRefresh(options);
    _handleResultException(result);

    final data = result.data?['updateTask'];

    return Task.fromTwenty(data);
  }

  @override
  Future<void> deleteTask(String id) async {
    const String mutation = r'''
      mutation DeleteTask($id: UUID!) {
        deleteTask(id: $id) { id }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: parseString(mutation),
      variables: {'id': id},
    );

    final QueryResult result = await _mutateWithRefresh(options);
    if (result.hasException) throw Exception(result.exception.toString());
  }
}
