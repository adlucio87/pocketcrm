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

    // Isoliamo ogni chiamata con un try/catch per capire ESATTAMENTE
    // quale query fa arrabbiare il complexity limiter di Twenty.
    final List<Task> overdueTasks = [];
    final List<Task> todayTasks = [];
    final List<Task> tomorrowTasks = [];
    final List<Contact> recentContacts = [];

    try {
      print('>>> [1/4] TEST: Fetching overdueTasks...');
      final res = await repo.getOverdueTasks();
      overdueTasks.addAll(res);
      print('>>> [1/4] SUCCESS: overdueTasks');
    } catch (e) {
      print('>>> [1/4] ERROR: overdueTasks failed: $e');
    }

    try {
      print('>>> [2/4] TEST: Fetching todayTasks...');
      final res = await repo.getTodayTasks();
      todayTasks.addAll(res);
      print('>>> [2/4] SUCCESS: todayTasks');
    } catch (e) {
      print('>>> [2/4] ERROR: todayTasks failed: $e');
    }

    try {
      print('>>> [3/4] TEST: Fetching tomorrowTasks...');
      final res = await repo.getTomorrowTasks();
      tomorrowTasks.addAll(res);
      print('>>> [3/4] SUCCESS: tomorrowTasks');
    } catch (e) {
      print('>>> [3/4] ERROR: tomorrowTasks failed: $e');
    }

    try {
      print('>>> [4/4] TEST: Fetching recentContacts...');
      final res = await repo.getRecentContacts(limit: 5);
      recentContacts.addAll(res);
      print('>>> [4/4] SUCCESS: recentContacts');
    } catch (e) {
      print('>>> [4/4] ERROR: recentContacts failed: $e');
    }

    return TodayData(
      overdueTasks: overdueTasks,
      todayTasks: todayTasks,
      tomorrowTasks: tomorrowTasks,
      recentContacts: recentContacts,
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