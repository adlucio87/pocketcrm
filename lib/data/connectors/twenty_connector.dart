import 'dart:convert';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:pocketcrm/domain/models/company.dart';
import 'package:pocketcrm/domain/models/contact.dart';
import 'package:pocketcrm/domain/models/note.dart';
import 'package:pocketcrm/domain/models/task.dart';
import 'package:pocketcrm/domain/models/workflow/workflow.dart';
import 'package:pocketcrm/data/graphql/workflow_queries.dart';
import 'package:pocketcrm/shared/widgets/phone_input_field.dart';
import 'package:pocketcrm/core/data/country_codes.dart';
import 'package:pocketcrm/domain/repositories/crm_repository.dart';

class TwentyConnector implements CRMRepository {
  final GraphQLClient client;

  TwentyConnector({required this.client});

  void _handleResultException(QueryResult result) {
    if (!result.hasException) return;
    
    final exception = result.exception!;
    final linkException = exception.linkException;
    
    if (linkException != null) {
      final errorStr = linkException.toString();
      if (errorStr.contains('SocketException') || 
          errorStr.contains('NetworkError') || 
          errorStr.contains('Connection closed')) {
        throw Exception('It seems there\'s no internet connection. Please check your settings.');
      }
      if (errorStr.contains('Connection refused') || 
          errorStr.contains('404') || 
          errorStr.contains('Network unreachable')) {
        throw Exception('The CRM endpoint is unreachable. Please verify the URL in settings.');
      }
      throw Exception('Connection error: $errorStr');
    }

    if (exception.graphqlErrors.isNotEmpty) {
      final error = exception.graphqlErrors.first;
      final msg = error.message.toLowerCase();
      if (msg.contains('unauthorized') || msg.contains('forbidden')) {
        throw Exception('Session expired or invalid token. Please reconnect in settings.');
      }
      throw Exception(error.message);
    }
    
    throw Exception('An unexpected error occurred while communicating with the server.');
  }

  @override
  Future<bool> testConnection(String baseUrl, String apiToken) async {
    const String query = r'''
      query Me {
        workspaceMembers(first: 1) {
          edges {
            node {
              id
              name { firstName lastName }
            }
          }
        }
      }
    ''';

    try {
      final tempLink = HttpLink(
        '$baseUrl/graphql',
        defaultHeaders: {'Authorization': 'Bearer $apiToken'},
      );
      
      final tempClient = GraphQLClient(
        link: tempLink, 
        cache: GraphQLCache(),
      );

      final QueryResult result = await tempClient.query(
        QueryOptions(
          document: gql(query),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        final exception = result.exception!;
        if (exception.graphqlErrors.isNotEmpty) {
          final error = exception.graphqlErrors.first;
          // Check for common auth errors
          if (error.message.toLowerCase().contains('unauthorized') || 
              error.message.toLowerCase().contains('forbidden')) {
            throw Exception('Invalid API Token');
          }
          throw Exception(error.message);
        }
        
        if (exception.linkException != null) {
          final linkError = exception.linkException.toString();
          if (linkError.contains('404')) {
            throw Exception('URL not found. Verify your Instance URL.');
          }
          if (linkError.contains('Connection refused') || linkError.contains('SocketException')) {
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
    } catch (e) {
      rethrow;
    }
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
    final QueryOptions options = QueryOptions(document: gql(query));
    final QueryResult result = await client.query(options);

    final edges = result.data?['workspaceMembers']?['edges'] as List?;
    if (edges == null || edges.isEmpty) return '';
    
    final name = edges.first['node']?['name'];
    if (name == null) return '';
    return '${name['firstName']} ${name['lastName']}'.trim();
  }

  @override
  Future<({List<Contact> contacts, String? endCursor, bool hasNextPage})> getContacts({
    String? search,
    int pageSize = 20,
    String? after,
  }) async {
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
          {'name': {'firstName': {'ilike': '%$search%'}}},
          {'name': {'lastName': {'ilike': '%$search%'}}},
        ],
      };
    }

    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: {
        'first': pageSize,
        if (filter != null) 'filter': filter,
        if (after != null) 'after': after,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);
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
      document: gql(query),
      variables: {'id': id},
    );

    final QueryResult result = await client.query(options);
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
      document: gql(query),
      variables: {
        'filter': {
          'companyId': {'eq': companyId},
        },
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);
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
      document: gql(query),
      variables: {
        'filter': {
          'taskId': {'eq': taskId},
        },
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);
    _handleResultException(result);

    final edges = result.data?['taskTargets']?['edges'] as List?;
    if (edges == null) return [];

    return edges
        .where((e) => e['node']?['targetPerson'] != null)
        .map((e) => Contact.fromTwenty(e['node']['targetPerson'] as Map<String, dynamic>))
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
      if (phone != null) 'phones': {
        'primaryPhoneNumber': phone,
        if (phoneCountryCode != null) 'primaryPhoneCountryCode': phoneCountryCode,
      },
    };

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {'input': input},
    );

    final QueryResult result = await client.mutate(options);
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
  }) async {
    const String mutation = r'''
      mutation UpdatePerson($id: UUID!, $input: PersonUpdateInput!) {
        updatePerson(id: $id, data: $input) {
          id
          name { firstName lastName }
          emails { primaryEmail }
          phones { primaryPhoneNumber primaryPhoneCallingCode }
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
        if (phoneCountryCode != null) 'primaryPhoneCountryCode': phoneCountryCode,
      };
    }

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {'id': id, 'input': input},
    );

    final QueryResult result = await client.mutate(options);
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
      document: gql(mutation),
      variables: {'id': id},
    );

    final QueryResult result = await client.mutate(options);
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
          {'name': {'like': '%$search%'}},
          {'domainName': {'primaryLinkUrl': {'like': '%$search%'}}},
        ],
      };
    }

    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: {'first': 20, if (filter != null) 'filter': filter},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);
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
      document: gql(query),
      variables: {'id': id},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);
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
      document: gql(query),
      variables: {'companyId': companyId},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);
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
      document: gql(query),
      variables: {'personId': contactId},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);
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
          {"type": "text", "text": body, "styles": {}}
        ]
      }
    ]);

    final input = <String, dynamic>{
      'bodyV2': {
        'blocknote': blockNodeJson,
      }
    };

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {'input': input},
    );

    final QueryResult result = await client.mutate(options);
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
      document: gql(targetMutation),
      variables: {'input': targetInput},
    );
    final targetResult = await client.mutate(targetOptions);
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
          {"type": "text", "text": body, "styles": {}}
        ]
      }
    ]);

    final input = <String, dynamic>{
      'bodyV2': {
        'blocknote': blockNodeJson,
      }
    };

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {'id': id, 'input': input},
    );

    final QueryResult result = await client.mutate(options);
    _handleResultException(result);

    return Note.fromTwenty(
      result.data?['updateNote'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteNote(String id) async {
    const String mutation = r'''
      mutation DeleteNote($id: UUID!) {
        deleteNote(id: $id) { id }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {'id': id},
    );

    final QueryResult result = await client.mutate(options);
    _handleResultException(result);
  }

  @override
  Future<List<Task>> getOverdueTasks() async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    final String query = '''
      query GetOverdueTasks {
        tasks(
          filter: {
            and: [
              { dueAt: { lt: "${startOfToday.toIso8601String()}" } }
              { status: { neq: DONE } }
            ]
          }
          orderBy: { dueAt: AscNullsLast }
        ) {
          edges { node { id title status dueAt } }
        }
      }
    ''';

    final options = QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final result = await client.query(options);

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

    final String query = '''
      query GetTodayTasks {
        tasks(
          filter: {
            and: [
              { dueAt: { gte: "${startOfToday.toIso8601String()}" } }
              { dueAt: { lt: "${endOfToday.toIso8601String()}" } }
              { status: { neq: DONE } }
            ]
          }
          orderBy: { dueAt: AscNullsLast }
        ) {
          edges { node { id title status dueAt } }
        }
      }
    ''';

    final options = QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final result = await client.query(options);

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
    final startOfTomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final endOfTomorrow = startOfTomorrow.add(const Duration(days: 1));

    final String query = '''
      query GetTomorrowTasks {
        tasks(
          filter: {
            and: [
              { dueAt: { gte: "${startOfTomorrow.toIso8601String()}" } }
              { dueAt: { lt: "${endOfTomorrow.toIso8601String()}" } }
              { status: { neq: DONE } }
            ]
          }
          orderBy: { dueAt: AscNullsLast }
        ) {
          edges { node { id title status dueAt } }
        }
      }
    ''';

    final options = QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final result = await client.query(options);

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
      document: gql(query),
      variables: {'first': limit},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final result = await client.query(options);
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
            }
          }
        }
      }
    ''';

    Map<String, dynamic>? filter;
    if (completed != null) {
      filter = {
        'status': {'eq': completed ? 'DONE' : 'TODO'},
      };
    }

    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: {if (filter != null) 'filter': filter},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);
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
  }) async {
    const String mutation = r'''
      mutation CreateTask($input: TaskCreateInput!) {
        createTask(data: $input) { id title status bodyV2 { blocknote } dueAt createdAt }
      }
    ''';

    final input = <String, dynamic>{
      'title': title,
    };
    if (body != null) {
      final blockNodeJson = jsonEncode([
        {
          "type": "paragraph",
          "content": [
            {"type": "text", "text": body, "styles": {}}
          ]
        }
      ]);
      input['bodyV2'] = {
        'blocknote': blockNodeJson,
      };
    }
    if (dueAt != null) {
      final utcDueAt = dueAt.toUtc();
      input['dueAt'] = "${utcDueAt.toIso8601String().split('.')[0]}Z";
    }

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {'input': input},
    );

    final QueryResult result = await client.mutate(options);
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
          document: gql(targetMutation),
          variables: {'input': targetInput},
        );
        final targetResult = await client.mutate(targetOptions);
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
  }) async {
    const String mutation = r'''
      mutation UpdateTask($id: UUID!, $input: TaskUpdateInput!) {
        updateTask(id: $id, data: $input) { id title status bodyV2 { blocknote } dueAt createdAt }
      }
    ''';

    final input = <String, dynamic>{};
    if (title != null) input['title'] = title;
    if (completed != null) {
      input['status'] = completed ? 'DONE' : 'TODO';
    }
    if (body != null) {
      final blockNodeJson = jsonEncode([
        {
          "type": "paragraph",
          "content": [
            {"type": "text", "text": body, "styles": {}}
          ]
        }
      ]);
      input['bodyV2'] = {
        'blocknote': blockNodeJson,
      };
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
      document: gql(mutation),
      variables: {
        'id': id,
        'input': input,
      },
    );

    final QueryResult result = await client.mutate(options);
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
      document: gql(mutation),
      variables: {'id': id},
    );

    final QueryResult result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());
  }

  @override
  Future<List<Workflow>> getManualWorkflows(String objectType) async {
    final QueryOptions options = QueryOptions(
      document: gql(getManualWorkflowsQuery),
      variables: {
        'objectType': objectType,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);
    _handleResultException(result);

    if (result.data?['workflows']?['edges'] == null) {
      return [];
    }

    final List edges = result.data!['workflows']['edges'];
    return edges.map((e) => Workflow.fromTwenty(e['node'])).toList();
  }

  @override
  Future<bool> executeManualWorkflow(String workflowId, String recordId, Map<String, dynamic> payload) async {
    final MutationOptions options = MutationOptions(
      document: gql(executeManualWorkflowMutation),
      variables: {
        'workflowId': workflowId,
        'recordId': recordId,
        'payload': payload,
      },
    );

    final QueryResult result = await client.mutate(options);
    _handleResultException(result);

    final bool success = result.data?['triggerWorkflow']?['success'] ?? false;
    if (!success && result.data?['triggerWorkflow']?['error']?['message'] != null) {
        throw Exception(result.data!['triggerWorkflow']['error']['message']);
    }
    return success;
  }

}
