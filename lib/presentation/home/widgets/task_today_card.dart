import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketcrm/domain/models/task.dart';
import 'package:pocketcrm/presentation/home/today_provider.dart';

class TaskTodayCard extends ConsumerWidget {
  final Task task;
  final bool isOverdue;

  const TaskTodayCard({super.key, required this.task, this.isOverdue = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
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
          onChanged: (_) => ref.read(todayNotifierProvider.notifier)
            .completeTask(task.id),
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
        trailing: task.dueAt != null ? Text(
          _formatTime(task.dueAt!),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isOverdue ? Theme.of(context).colorScheme.error : null,
            fontWeight: isOverdue ? FontWeight.w600 : null,
          ),
        ) : null,
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (isOverdue) {
      if (diff.inDays == 1) return 'Ieri';
      if (diff.inDays > 1) return '${diff.inDays}g fa';
    }
    return '${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}';
  }
}
