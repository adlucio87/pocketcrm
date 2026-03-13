import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:pocketcrm/domain/models/task.dart';
import 'package:pocketcrm/domain/models/contact.dart';

part 'today_provider.freezed.dart';
part 'today_provider.g.dart';

@riverpod
class TodayNotifier extends _$TodayNotifier {
  @override
  Future<TodayData> build() async {
    return _loadTodayData();
  }

  Future<TodayData> _loadTodayData() async {
    final repo = await ref.read(crmRepositoryProvider.future);

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));
    final startOfTomorrow = endOfToday;
    final endOfTomorrow = startOfTomorrow.add(const Duration(days: 1));

    // Esegui tutte le query in parallelo
    final results = await Future.wait([
      repo.getOverdueTasks(),           // dueAt < oggi, status != DONE
      repo.getTodayTasks(),             // dueAt = oggi, status != DONE
      repo.getTomorrowTasks(),          // dueAt = domani, status != DONE
      repo.getRecentContacts(limit: 5), // ultimi 5 per updatedAt
    ]);

    return TodayData(
      overdueTasks: results[0] as List<Task>,
      todayTasks: results[1] as List<Task>,
      tomorrowTasks: results[2] as List<Task>,
      recentContacts: results[3] as List<Contact>,
    );
  }

  Future<void> completeTask(String taskId) async {
    // Aggiorniamo lo status passando completed: true al metodo esistente
    final repo = await ref.read(crmRepositoryProvider.future);
    await repo.updateTask(taskId, completed: true);
    ref.invalidateSelf(); // ricarica tutto
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

@freezed
class TodayData with _$TodayData {
  factory TodayData({
    required List<Task> overdueTasks,
    required List<Task> todayTasks,
    required List<Task> tomorrowTasks,
    required List<Contact> recentContacts,
  }) = _TodayData;
}