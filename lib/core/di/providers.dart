import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketcrm/core/utils/storage_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:pocketcrm/data/connectors/twenty_connector.dart';
import 'package:pocketcrm/domain/models/company.dart';
import 'package:pocketcrm/domain/models/contact.dart';
import 'package:pocketcrm/domain/models/task.dart';
import 'package:pocketcrm/domain/repositories/crm_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) {
  throw UnimplementedError(); // Overridden in main.dart
}

@Riverpod(keepAlive: true)
StorageService storageService(StorageServiceRef ref) {
  const secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final fallback = ref.watch(sharedPreferencesProvider);
  return StorageService(secure, fallback);
}

@Riverpod(keepAlive: true)
Future<CRMRepository> crmRepository(CrmRepositoryRef ref) async {
  final storage = ref.watch(storageServiceProvider);
  final baseUrl = await storage.read(key: 'instance_url');
  final apiToken = await storage.read(key: 'api_token');

  if (baseUrl == null || apiToken == null) {
    throw Exception('Not connected');
  }

  final link = HttpLink(
    '$baseUrl/graphql', // Twenty CRM graphql endpoint
    defaultHeaders: {'Authorization': 'Bearer $apiToken'},
  );

  final client = GraphQLClient(link: link, cache: GraphQLCache());

  return TwentyConnector(client: client);
}

@riverpod
class Contacts extends _$Contacts {
  @override
  FutureOr<List<Contact>> build() async {
    final repo = await ref.watch(crmRepositoryProvider.future);
    return repo.getContacts();
  }

  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.watch(crmRepositoryProvider.future);
      return repo.getContacts(search: query);
    });
  }

  Future<void> addContact({
    required String firstName,
    required String lastName,
    String? email,
    String? phone,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(crmRepositoryProvider.future);
      await repo.createContact(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
      );
      return repo.getContacts();
    });
  }
}

@riverpod
class ContactDetail extends _$ContactDetail {
  @override
  FutureOr<Contact> build(String id) async {
    final repo = await ref.watch(crmRepositoryProvider.future);
    return repo.getContactById(id);
  }
}

@riverpod
class Companies extends _$Companies {
  @override
  FutureOr<List<Company>> build() async {
    final repo = await ref.watch(crmRepositoryProvider.future);
    return repo.getCompanies();
  }

  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.watch(crmRepositoryProvider.future);
      return repo.getCompanies(search: query);
    });
  }
}

@riverpod
class Tasks extends _$Tasks {
  @override
  FutureOr<List<Task>> build() async {
    final repo = await ref.watch(crmRepositoryProvider.future);
    return repo.getTasks();
  }

  Future<void> filterCompleted(bool completed) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.watch(crmRepositoryProvider.future);
      return repo.getTasks(completed: completed);
    });
  }

  Future<void> toggleTask(String id, bool currentlyCompleted) async {
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(crmRepositoryProvider.future);
      if (currentlyCompleted) {
        // Twenty non ha un "uncomplete" semplice nel repository interface ora,
        // ma possiamo mappare status a TODO/DONE.
        // Per ora implementiamo solo completeTask come da repo.
        await repo.completeTask(id);
      } else {
        await repo.completeTask(id);
      }
      return repo.getTasks();
    });
  }

  Future<void> addTask(String title, {DateTime? dueAt, String? contactId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(crmRepositoryProvider.future);
      await repo.createTask(title: title, dueAt: dueAt, contactId: contactId);
      return repo.getTasks();
    });
  }
}
