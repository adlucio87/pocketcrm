import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketcrm/domain/models/task.dart';
import 'package:pocketcrm/presentation/home/today_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketcrm/presentation/shared/swipe_to_delete_wrapper.dart';
import 'package:pocketcrm/presentation/shared/snackbar_helper.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:pocketcrm/core/utils/demo_utils.dart';

class TaskTodayCard extends ConsumerWidget {
  final Task task;
  final bool isOverdue;

  const TaskTodayCard({super.key, required this.task, this.isOverdue = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SwipeToDeleteWrapper(
      itemKey: ValueKey('today_task_${task.id}'),
      confirmTitle: 'Elimina task',
      confirmMessage: 'Vuoi eliminare \'${task.title}\'?',
      onDelete: () async {
        if (!await DemoUtils.checkDemoAction(context, ref)) return;
        try {
          await ref.read(tasksProvider.notifier).deleteTask(task.id);
          ref.invalidate(todayNotifierProvider);
          if (context.mounted) {
            SnackbarHelper.showSuccess(context, 'Task eliminato');
          }
        } catch (e) {
          if (context.mounted) {
            SnackbarHelper.showError(context, 'Errore durante l\'eliminazione');
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
        color: isOverdue
          ? Theme.of(context).colorScheme.error.withOpacity(0.08)
          : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue
            ? Theme.of(context).colorScheme.error.withOpacity(0.3)
            : Theme.of(context).dividerColor,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Checkbox(
          value: task.completed ?? false,
          onChanged: (_) async {
            if (!await DemoUtils.checkDemoAction(context, ref)) return;
            ref.read(todayNotifierProvider.notifier).completeTask(task.id);
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            decoration: (task.completed ?? false)
              ? TextDecoration.lineThrough
              : null,
          ),
        ),
        subtitle: task.contactName != null ? Row(
          children: [
            const Icon(Icons.person_outline, size: 12),
            const SizedBox(width: 4),
            Text(task.contactName!,
              style: Theme.of(context).textTheme.bodySmall),
          ],
        ) : null,
          trailing: task.dueAt != null ? _buildTrailing(context, task.dueAt!) : null,
        ),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context, DateTime date) {
    final hasTime = date.hour != 0 || date.minute != 0;

    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        bool hasNotification = false;
        if (snapshot.hasData) {
          hasNotification = snapshot.data!.getBool('task_notif_${task.id}') ?? true;
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasTime && hasNotification) ...[
              Icon(
                Icons.notifications_active,
                size: 14,
                color: isOverdue ? Theme.of(context).colorScheme.error : null,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              _formatTime(date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isOverdue ? Theme.of(context).colorScheme.error : null,
                fontWeight: isOverdue ? FontWeight.w600 : null,
              ),
            ),
          ],
        );
      }
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final hasTime = date.hour != 0 || date.minute != 0;
    final diff = now.difference(date);

    if (isOverdue) {
      if (diff.inDays == 1) return 'Ieri';
      if (diff.inDays > 1) return '${diff.inDays}g fa';
    }

    if (!hasTime) return 'Oggi';

    return '${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}';
  }
}
