import 'package:pocketcrm/domain/models/company.dart';
import 'package:pocketcrm/domain/models/contact.dart';
import 'package:pocketcrm/domain/models/note.dart';
import 'package:pocketcrm/domain/models/task.dart';
import 'package:pocketcrm/domain/models/workflow/workflow.dart';

abstract class CRMRepository {
  // Auth
  Future<bool> testConnection(String baseUrl, String apiToken);
  Future<String> getCurrentUserName();

  // Contacts
  Future<({List<Contact> contacts, String? endCursor, bool hasNextPage})> getContacts({
    String? search,
    int pageSize = 20,
    String? after,
  });
  Future<List<Contact>> getContactsByCompany(String companyId);
  Future<List<Contact>> getContactsByTask(String taskId);
  Future<Contact> getContactById(String id);
  Future<Contact> createContact({
    required String firstName,
    required String lastName,
    String? email,
    String? phone,
  });
  Future<Contact> updateContact(
    String id, {
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  });
  Future<void> deleteContact(String id);

  // Companies
  Future<List<Company>> getCompanies({String? search, int page = 1});
  Future<Company> getCompanyById(String id);

  // Notes
  Future<List<Note>> getNotesByContact(String contactId);
  Future<List<Note>> getNotesByCompany(String companyId);
  Future<Note> createNote({required String contactId, required String body, DateTime? dueAt});
  Future<Note> updateNote(String id, {required String body, DateTime? dueAt});
  Future<void> deleteNote(String id);


  // Tasks
  Future<List<Task>> getTasks({bool? completed});
  Future<List<Task>> getOverdueTasks();
  Future<List<Task>> getTodayTasks();
  Future<List<Task>> getTomorrowTasks();
  Future<Task> createTask({
    required String title,
    String? body,
    DateTime? dueAt,
    String? contactId,
  });
  Future<Task> updateTask(String id, {
    String? title,
    String? body,
    DateTime? dueAt,
    bool clearDueDate = false,
    bool? completed,
  });
  Future<void> deleteTask(String id);

  // Workflows
  Future<List<Workflow>> getManualWorkflows(String objectType);
  Future<bool> executeManualWorkflow(String workflowId, String recordId, Map<String, dynamic> payload);

  // Today screen queries
  Future<List<Contact>> getRecentContacts({int limit = 5});
}
