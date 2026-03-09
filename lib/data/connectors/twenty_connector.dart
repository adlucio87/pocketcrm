import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:pocketcrm/domain/models/company.dart';
import 'package:pocketcrm/domain/models/contact.dart';
import 'package:pocketcrm/domain/models/note.dart';
import 'package:pocketcrm/domain/models/task.dart';
import 'package:pocketcrm/domain/repositories/crm_repository.dart';

class TwentyConnector implements CRMRepository {
  final GraphQLClient client;

  TwentyConnector({required this.client});

  @override
  Future<bool> testConnection(String baseUrl, String apiToken) async {
    const String query = r'''
      query Me {
        currentWorkspaceMember {
          id
          name
        }
      }
    ''';

    // Per il test potremmo usare un client temporaneo se i token sono nuovi
    final tempLink = HttpLink(
      '$baseUrl/graphql', // Utilizziamo graphql o api/graphql in base all'istanza
      defaultHeaders: {'Authorization': 'Bearer $apiToken'},
    );
    final tempClient = GraphQLClient(link: tempLink, cache: GraphQLCache());

    final QueryOptions options = QueryOptions(document: gql(query));
    final QueryResult result = await tempClient.query(options);

    if (result.hasException) {
      return false;
    }
    return result.data?['currentWorkspaceMember'] != null;
  }

  @override
  Future<String> getCurrentUserName() async {
    const String query = r'''
      query Me {
        currentWorkspaceMember {
          name
        }
      }
    ''';
    final QueryOptions options = QueryOptions(document: gql(query));
    final QueryResult result = await client.query(options);

    if (result.hasException) throw Exception(result.exception.toString());
    return result.data?['currentWorkspaceMember']?['name'] ?? '';
  }

  @override
  Future<List<Contact>> getContacts({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    const String query = r'''
      query GetPeople($filter: PersonFilterInput, $first: Int) {
        people(filter: $filter, first: $first, orderBy: { createdAt: DescNullsLast }) {
          edges {
            node {
              id
              name { firstName lastName }
              emails { primaryEmail }
              phones { primaryPhoneNumber }
              avatarUrl
              company { id name }
              createdAt
              updatedAt
            }
          }
        }
      }
    ''';

    Map<String, dynamic>? filter;
    if (search != null && search.isNotEmpty) {
      filter = {
        'firstName': {'contains': search},
      };
    }

    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: {'first': pageSize, if (filter != null) 'filter': filter},
    );

    final QueryResult result = await client.query(options);
    if (result.hasException) throw Exception(result.exception.toString());

    final edges = result.data?['people']?['edges'] as List?;
    if (edges == null) return [];

    return edges
        .map((e) => Contact.fromTwenty(e['node'] as Map<String, dynamic>))
        .toList();
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
              phones { primaryPhoneNumber additionalPhones }
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
    if (result.hasException) throw Exception(result.exception.toString());

    final edges = result.data?['people']?['edges'] as List?;
    if (edges == null || edges.isEmpty) throw Exception('Contact not found');

    return Contact.fromTwenty(edges.first['node'] as Map<String, dynamic>);
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

    final input = {
      'name': {'firstName': firstName, 'lastName': lastName},
      if (email != null) 'emails': {'primaryEmail': email},
      if (phone != null) 'phones': {'primaryPhoneNumber': phone},
    };

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {'input': input},
    );

    final QueryResult result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());

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
    // Implementazione base simile a createContact (tralasciata qui per brevità, da affinare se servono query complete)
    throw UnimplementedError();
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
              createdAt
            }
          }
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: {'first': 20},
    );

    final QueryResult result = await client.query(options);
    if (result.hasException) throw Exception(result.exception.toString());

    final edges = result.data?['companies']?['edges'] as List?;
    if (edges == null) return [];

    return edges
        .map((e) => Company.fromTwenty(e['node'] as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Company> getCompanyById(String id) {
    throw UnimplementedError();
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
    );

    final QueryResult result = await client.query(options);
    if (result.hasException) throw Exception(result.exception.toString());

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
  }) async {
    const String mutation = r'''
      mutation CreateNote($input: NoteCreateInput!) {
        createNote(data: $input) { id bodyV2 { blocknote } createdAt }
      }
    ''';

    final input = {'body': body};

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {'input': input},
    );

    final QueryResult result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());

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
  Future<List<Task>> getTasks({bool? completed}) async {
    const String query = r'''
      query GetTasks($filter: TaskFilterInput) {
        tasks(filter: $filter, orderBy: { createdAt: DescNullsLast }) {
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
    );

    final QueryResult result = await client.query(options);
    if (result.hasException) throw Exception(result.exception.toString());

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
        createTask(data: $input) { id title status dueAt createdAt }
      }
    ''';

    final input = {
      'title': title,
      if (body != null) 'body': body,
      if (dueAt != null) 'dueAt': dueAt.toIso8601String(),
    };

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {'input': input},
    );

    final QueryResult result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());

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
    return Task(
      id: data['id'],
      title: data['title'] ?? '',
      completed: data['status'] == 'DONE',
      dueAt: data['dueAt'] != null ? DateTime.parse(data['dueAt']) : null,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : null,
    );
  }

  @override
  Future<Task> completeTask(String id) async {
    const String mutation = r'''
      mutation UpdateTask($id: UUID!, $input: TaskUpdateInput!) {
        updateTask(id: $id, data: $input) { id status }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'id': id,
        'input': {'status': 'DONE'},
      },
    );

    final QueryResult result = await client.mutate(options);
    if (result.hasException) throw Exception(result.exception.toString());

    final data = result.data?['updateTask'];
    return Task(
      id: data['id'],
      title: '', // Richiede query completa se serve tutto il task
      completed: data['status'] == 'DONE',
    );
  }
}
