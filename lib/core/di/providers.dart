import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pocketcrm/core/utils/storage_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:pocketcrm/data/connectors/twenty_connector.dart';
import 'package:pocketcrm/domain/models/company.dart';
import 'package:pocketcrm/domain/models/contact.dart';
import 'package:pocketcrm/domain/models/note.dart';
import 'package:pocketcrm/domain/models/task.dart';
import 'package:pocketcrm/domain/repositories/crm_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pocketcrm/core/notifications/notification_service.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
Box<String> hiveStorageBox(HiveStorageBoxRef ref) {
  throw UnimplementedError(); // Overridden in main.dart
}

@Riverpod(keepAlive: true)
StorageService storageService(StorageServiceRef ref) {
  const secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final box = ref.watch(hiveStorageBoxProvider);
  return StorageService(secure, box);
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

@Riverpod(keepAlive: true)
class Contacts extends _$Contacts {
  String? _endCursor;
  bool _hasNextPage = false;
  bool _isLoadingMore = false;
  String? _currentSearch;

  @override
  FutureOr<List<Contact>> build() async {
    _endCursor = null;
    _hasNextPage = false;
    _currentSearch = null;
    final repo = await ref.watch(crmRepositoryProvider.future);
    final result = await repo.getContacts();
    _endCursor = result.endCursor;
    _hasNextPage = result.hasNextPage;
    return result.contacts;
  }

  Future<void> search(String query) async {
    _endCursor = null;
    _hasNextPage = false;
    _currentSearch = query.isEmpty ? null : query;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(crmRepositoryProvider.future);
      final result = await repo.getContacts(search: _currentSearch);
      _endCursor = result.endCursor;
      _hasNextPage = result.hasNextPage;
      return result.contacts;
    });
  }

  bool get hasNextPage => _hasNextPage;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasNextPage || _endCursor == null) return;
    final current = state.value;
    if (current == null) return;

    _isLoadingMore = true;
    try {
      final repo = await ref.read(crmRepositoryProvider.future);
      final result = await repo.getContacts(
        search: _currentSearch,
        after: _endCursor,
      );
      _endCursor = result.endCursor;
      _hasNextPage = result.hasNextPage;
      state = AsyncValue.data([...current, ...result.contacts]);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<Contact> addContact({
    required String firstName,
    required String lastName,
    String? email,
    String? phone,
  }) async {
    final repo = await ref.read(crmRepositoryProvider.future);
    final newContact = await repo.createContact(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
    );
    
    // Aggiorniamo ottimisticamente lo stato inserendo il nuovo contatto in cima 
    // alla lista attuale. In questo modo l'UI si aggiorna all'istante!
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data([newContact, ...currentState]);
    } else {
      // Se era vuoto o in errore, forziamo il reload dal backend
      ref.invalidateSelf();
    }
    
    return newContact;
  }

  Future<Contact> updateContact(
    String id, {
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) async {
    final repo = await ref.read(crmRepositoryProvider.future);
    final updatedContact = await repo.updateContact(
      id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
    );
    
    // Optimistic update: replace the old contact with the updated one
    final currentState = state.value;
    if (currentState != null) {
      final index = currentState.indexWhere((c) => c.id == id);
      if (index != -1) {
        final newList = [...currentState];
        // We preserve some fields like avatarUrl and company that the update 
        // mutation might not return fully, by merging with the old contact.
        // Wait, updatePerson returns the updated fields. Let's merge.
        final oldContact = newList[index];
        newList[index] = oldContact.copyWith(
          firstName: updatedContact.firstName.isNotEmpty ? updatedContact.firstName : oldContact.firstName,
          lastName: updatedContact.lastName.isNotEmpty ? updatedContact.lastName : oldContact.lastName,
          email: updatedContact.email ?? oldContact.email,
          phone: updatedContact.phone ?? oldContact.phone,
        );
        state = AsyncValue.data(newList);
      }
    }
    
    // Also invalidate the contactDetailProvider for this specific contact
    // so the detail screen gets the fresh data next time it's accessed or currently viewed.
    ref.invalidate(contactDetailProvider(id));
    
    return updatedContact;
  }

  Future<void> deleteContact(String id) async {
    final currentState = state.value;
    List<Contact>? previousState;

    // Optimistic update
    if (currentState != null) {
      previousState = List.from(currentState);
      final newList = currentState.where((c) => c.id != id).toList();
      state = AsyncValue.data(newList);
    }

    try {
      final repo = await ref.read(crmRepositoryProvider.future);
      await repo.deleteContact(id);

      // Invalidate related providers or detail providers
      ref.invalidate(contactDetailProvider(id));
    } catch (e) {
      // Revert optimistic update on error
      if (previousState != null) {
        state = AsyncValue.data(previousState);
      } else {
        ref.invalidateSelf();
      }
      rethrow;
    }
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
class ContactNotes extends _$ContactNotes {
  @override
  FutureOr<List<Note>> build(String id) async {
    final repo = await ref.watch(crmRepositoryProvider.future);
    return repo.getNotesByContact(id);
  }

  Future<Note> updateNote(String noteId, String body, {DateTime? dueAt}) async {
    final repo = await ref.read(crmRepositoryProvider.future);
    final updatedNote = await repo.updateNote(noteId, body: body, dueAt: dueAt);

    final currentState = state.value;
    if (currentState != null) {
      final index = currentState.indexWhere((n) => n.id == noteId);
      if (index != -1) {
        final newList = [...currentState];
        newList[index] = updatedNote;
        state = AsyncValue.data(newList);
      }
    }

    return updatedNote;
  }

  Future<Note> addNote(String contactId, String body, {DateTime? dueAt}) async {
    final repo = await ref.read(crmRepositoryProvider.future);
    final newNote = await repo.createNote(
      contactId: contactId,
      body: body,
      dueAt: dueAt,
    );

    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data([newNote, ...currentState]);
    } else {
      ref.invalidateSelf();
    }

    return newNote;
  }

  Future<void> deleteNote(String noteId) async {
    final currentState = state.value;
    List<Note>? previousState;

    if (currentState != null) {
      previousState = List.from(currentState);
      final newList = currentState.where((n) => n.id != noteId).toList();
      state = AsyncValue.data(newList);
    }

    try {
      final repo = await ref.read(crmRepositoryProvider.future);
      await repo.deleteNote(noteId);
    } catch (e) {
      if (previousState != null) {
        state = AsyncValue.data(previousState);
      } else {
        ref.invalidateSelf();
      }
      rethrow;
    }
  }
}


@riverpod
class CompanyDetail extends _$CompanyDetail {
  @override
  FutureOr<Company> build(String id) async {
    final repo = await ref.watch(crmRepositoryProvider.future);
    return repo.getCompanyById(id);
  }
}

@riverpod
class CompanyNotes extends _$CompanyNotes {
  @override
  FutureOr<List<Note>> build(String id) async {
    final repo = await ref.watch(crmRepositoryProvider.future);
    return repo.getNotesByCompany(id);
  }

  Future<Note> updateNote(String noteId, String body, {DateTime? dueAt}) async {
    final repo = await ref.read(crmRepositoryProvider.future);
    final updatedNote = await repo.updateNote(noteId, body: body, dueAt: dueAt);

    final currentState = state.value;
    if (currentState != null) {
      final index = currentState.indexWhere((n) => n.id == noteId);
      if (index != -1) {
        final newList = [...currentState];
        newList[index] = updatedNote;
        state = AsyncValue.data(newList);
      }
    }

    return updatedNote;
  }

  Future<Note> addNote(String companyId, String body, {DateTime? dueAt}) async {
    final repo = await ref.read(crmRepositoryProvider.future);
    final newNote = await repo.createNote(
      contactId: '', // Usually handled differently for companies, but matching signature
      body: body,
      dueAt: dueAt,
    );

    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data([newNote, ...currentState]);
    } else {
      ref.invalidateSelf();
    }

    return newNote;
  }

  Future<void> deleteNote(String noteId) async {
    final currentState = state.value;
    List<Note>? previousState;

    if (currentState != null) {
      previousState = List.from(currentState);
      final newList = currentState.where((n) => n.id != noteId).toList();
      state = AsyncValue.data(newList);
    }

    try {
      final repo = await ref.read(crmRepositoryProvider.future);
      await repo.deleteNote(noteId);
    } catch (e) {
      if (previousState != null) {
        state = AsyncValue.data(previousState);
      } else {
        ref.invalidateSelf();
      }
      rethrow;
    }
  }
}

@riverpod
class CompanyContacts extends _$CompanyContacts {
  @override
  FutureOr<List<Contact>> build(String id) async {
    final repo = await ref.watch(crmRepositoryProvider.future);
    return repo.getContactsByCompany(id);
  }
}

@riverpod
class TaskContacts extends _$TaskContacts {
  @override
  FutureOr<List<Contact>> build(String id) async {
    final repo = await ref.watch(crmRepositoryProvider.future);
    return repo.getContactsByTask(id);
  }
}

@Riverpod(keepAlive: true)
Future<String> currentUserName(CurrentUserNameRef ref) async {
  final repo = await ref.watch(crmRepositoryProvider.future);
  return repo.getCurrentUserName();
}

@Riverpod(keepAlive: true)
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
class TaskFilter extends _$TaskFilter {
  @override
  bool build() => false; // false = TODO, true = DONE

  void toggle() => state = !state;
}

@riverpod
class Tasks extends _$Tasks {
  @override
  FutureOr<List<Task>> build() async {
    final filter = ref.watch(taskFilterProvider);
    final repo = await ref.watch(crmRepositoryProvider.future);
    return repo.getTasks(completed: filter);
  }


  Future<Task> addTask(String title, {DateTime? dueAt, String? contactId}) async {
    final repo = await ref.read(crmRepositoryProvider.future);
    final newTask = await repo.createTask(
      title: title,
      dueAt: dueAt,
      contactId: contactId,
    );
    
    // Aggiorniamo ottimisticamente lo stato inserendo il nuovo task in cima 
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data([newTask, ...currentState]);
    } else {
      ref.invalidateSelf();
    }
    
    await NotificationService().scheduleTaskReminder(newTask);

    return newTask;
  }

  Future<Task> updateTask(String id, {String? title, String? body, DateTime? dueAt, bool clearDueDate = false, bool? completed}) async {
    final repo = await ref.read(crmRepositoryProvider.future);
    final updatedTask = await repo.updateTask(
      id,
      title: title,
      body: body,
      dueAt: dueAt,
      clearDueDate: clearDueDate,
      completed: completed,
    );

    final currentState = state.value;
    if (currentState != null) {
      final index = currentState.indexWhere((t) => t.id == id);
      if (index != -1) {
        final currentFilter = ref.read(taskFilterProvider);
        if (completed != null && completed != currentFilter) {
          // Se lo stato di completamento è cambiato ed è diverso dal filtro attivo,
          // rimuovi il task dalla lista attiva.
          final newList = [...currentState];
          newList.removeAt(index);
          state = AsyncValue.data(newList);
        } else {
          final newList = [...currentState];
          newList[index] = updatedTask;
          state = AsyncValue.data(newList);
        }
      }
    }

    if (updatedTask.completed == true) {
      await NotificationService().cancelTaskReminder(updatedTask.id);
    } else {
      await NotificationService().scheduleTaskReminder(updatedTask);
    }

    return updatedTask;
  }

  Future<void> deleteTask(String id) async {
    final currentState = state.value;
    List<Task>? previousState;

    if (currentState != null) {
      previousState = List.from(currentState);
      final newList = currentState.where((t) => t.id != id).toList();
      state = AsyncValue.data(newList);
    }

    try {
      final repo = await ref.read(crmRepositoryProvider.future);
      await repo.deleteTask(id);
      await NotificationService().cancelTaskReminder(id);
    } catch (e) {
      if (previousState != null) {
        state = AsyncValue.data(previousState);
      } else {
        ref.invalidateSelf();
      }
      rethrow;
    }
  }
}
