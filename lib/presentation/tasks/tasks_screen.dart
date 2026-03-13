import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:pocketcrm/core/di/auth_state.dart';
import 'package:pocketcrm/domain/models/contact.dart';
import 'package:pocketcrm/domain/models/task.dart';
import 'package:pocketcrm/presentation/shared/linked_contacts_widget.dart';
import 'package:pocketcrm/presentation/shared/due_date_picker.dart';
import 'package:pocketcrm/presentation/shared/skeleton_loading.dart';
import 'package:pocketcrm/presentation/shared/snackbar_helper.dart';
import 'package:pocketcrm/presentation/shared/empty_state_widget.dart';
import 'package:pocketcrm/core/notifications/notification_service.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {

  @override
  Widget build(BuildContext context) {
    ref.listen(tasksProvider, (previous, next) {
      next.whenData((tasks) {
        NotificationService().syncTaskNotifications(tasks);

        int overdueCount = tasks.where((t) => t.dueAt != null && t.dueAt!.isBefore(DateTime.now()) && t.completed != true).length;
        if (overdueCount > 0) {
          NotificationService().scheduleOvernightSummary(overdueCount);
        }
      });
    });

    final tasksAsync = ref.watch(tasksProvider);
    final isShowingCompleted = ref.watch(taskFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
            tooltip: 'Logout / Reset',
          ),
          IconButton(
            icon: Icon(
              isShowingCompleted ? Icons.check_box : Icons.check_box_outline_blank,
            ),
            onPressed: () {
              ref.read(taskFilterProvider.notifier).toggle();
            },
            tooltip: 'Filter completed',
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => ref.refresh(tasksProvider.future),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: EmptyStateWidget(
                    icon: isShowingCompleted ? Icons.task_alt : Icons.checklist,
                    title: isShowingCompleted ? 'No completed tasks' : 'All clear!',
                    message: isShowingCompleted
                        ? "You haven't checked any tasks yet."
                        : 'You have no pending tasks at the moment.',
                  ),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(tasksProvider.future),
            child: ListView.separated(
              itemCount: tasks.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  leading: Checkbox(
                    value: task.completed,
                    onChanged: (val) {
                      if (val != null) {
                        ref
                            .read(tasksProvider.notifier)
                            .updateTask(task.id, completed: val);
                        
                        SnackbarHelper.showSuccess(
                          context,
                          val ? 'Task completed' : 'Task restored',
                        );
                      }
                    },
                  ),
                  title: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      decoration: task.completed == true
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.completed == true ? Theme.of(context).textTheme.bodySmall?.color : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (context) {
                          if (task.dueAt == null) {
                            return Text('No deadline', style: Theme.of(context).textTheme.bodySmall);
                          }
                          
                          Color? dateColor = Theme.of(context).textTheme.bodySmall?.color;
                          FontWeight? dateWeight = FontWeight.w400;

                          if (task.completed != true) {
                            final now = DateTime.now();
                            final today = DateTime(now.year, now.month, now.day);
                            final dueDate = task.dueAt!.toLocal();
                            final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
                            
                            final difference = dueDay.difference(today).inDays;
                            
                            if (difference <= 0) {
                              dateColor = Theme.of(context).colorScheme.error; // Overdue or today
                              dateWeight = FontWeight.w600;
                            } else if (difference <= 3) {
                              dateColor = Colors.orange.shade700; // Next 3 days
                            }
                          }
                          
                          return Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: task.completed == true ? Theme.of(context).textTheme.bodySmall?.color : dateColor),
                              const SizedBox(width: 4),
                              Text(
                                'Due: ${task.dueAt!.toLocal().toString().split(' ')[0]}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: task.completed == true ? Theme.of(context).textTheme.bodySmall?.color : dateColor,
                                  fontWeight: task.completed == true ? FontWeight.w400 : dateWeight,
                                ),
                              ),
                            ],
                          );
                        }
                      ),
                      const SizedBox(height: 4),
                      LinkedContactsWidget(
                        entityId: task.id,
                        type: LinkedContactType.task,
                        isCompact: true,
                      ),
                    ],
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => _EditTaskSheet(task: task),
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const ListSkeleton(),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddTaskSheet(),
    );
  }
}

class _AddTaskSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<_AddTaskSheet> {
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedContactId;
  DateTime? _selectedDueDate;
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'New Task',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'What needs to be done?',
              ),
              autofocus: true,
              enabled: !_isLoading,
              validator: (v) =>
                  v?.trim().isEmpty == true ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),
            contactsAsync.when(
              data: (contacts) => Autocomplete<Contact>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<Contact>.empty();
                  }
                  return contacts.where((Contact contact) {
                    final fullName = '${contact.firstName} ${contact.lastName}'.toLowerCase();
                    return fullName.contains(textEditingValue.text.toLowerCase());
                  });
                },
                displayStringForOption: (Contact option) => '${option.firstName} ${option.lastName}',
                onSelected: (Contact selection) {
                  setState(() {
                    _selectedContactId = selection.id;
                  });
                },
                fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    onEditingComplete: onEditingComplete,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Search and link contact',
                      hintText: 'Start typing name...',
                    ),
                  );
                },
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Contacts error: $err'),
            ),
            const SizedBox(height: 16),
            DueDatePicker(
              selectedDate: _selectedDueDate,
              onDateSelected: (date) => setState(() => _selectedDueDate = date),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                         _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() { _errorMessage = null; });
                      if (_formKey.currentState!.validate()) {
                        setState(() { _isLoading = true; });
                        
                        final navigator = Navigator.of(context);
                        try {
                          await ref
                              .read(tasksProvider.notifier)
                              .addTask(
                              _titleController.text.trim(),
                              contactId: _selectedContactId,
                              dueAt: _selectedDueDate,
                            );
                              
                          if (mounted) {
                            navigator.pop(); // Chiudi solo in caso di successo
                            SnackbarHelper.showSuccess(context, 'Task created successfully');
                          }
                        } catch (e) {
                          if (mounted) {
                            String errorMsg = e.toString();
                            if (errorMsg.contains('Exception:')) {
                              errorMsg = errorMsg.replaceAll('Exception:', '').trim();
                            }
                            setState(() {
                              _isLoading = false;
                              _errorMessage = errorMsg;
                            });
                          }
                        }
                      }
                    },
              child: _isLoading
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2)
                    )
                  : const Text('Create Task'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _EditTaskSheet extends ConsumerStatefulWidget {
  final Task task;
  const _EditTaskSheet({required this.task});

  @override
  ConsumerState<_EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends ConsumerState<_EditTaskSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDueDate;
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _bodyController = TextEditingController(text: _extractPlainText(widget.task.body));
    _selectedDueDate = widget.task.dueAt;
  }

  String _extractPlainText(String? body) {
    if (body == null || body.isEmpty) return '';
    try {
      final decoded = jsonDecode(body);
      if (decoded is List) {
        final buffer = StringBuffer();
        for (final block in decoded) {
          if (block is Map && block['content'] != null) {
            final content = block['content'];
            if (content is List) {
              for (final inline in content) {
                if (inline is Map && inline['text'] != null) {
                  buffer.write(inline['text']);
                }
              }
            } else if (content is String) {
              buffer.write(content);
            }
          }
          buffer.writeln(); // new line per paragraph
        }
        return buffer.toString().trim();
      }
    } catch (_) {
      // Not JSON, return as is
    }
    return body;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit Task',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                autofocus: true,
                enabled: !_isLoading,
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Details (optional)',
                ),
                maxLines: 3,
                minLines: 1,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              DueDatePicker(
                selectedDate: _selectedDueDate,
                onDateSelected: (date) => setState(() => _selectedDueDate = date),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                           _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() { _errorMessage = null; });
                        if (_formKey.currentState!.validate()) {
                          setState(() { _isLoading = true; });
                          
                          final navigator = Navigator.of(context);
                          try {
                            await ref
                                .read(tasksProvider.notifier)
                                .updateTask(
                                  widget.task.id,
                                  title: _titleController.text.trim(),
                                  body: _bodyController.text.trim(),
                                  dueAt: _selectedDueDate,
                                  clearDueDate: _selectedDueDate == null,
                                );
                                
                            if (mounted) {
                              navigator.pop();
                              SnackbarHelper.showSuccess(context, 'Task updated successfully');
                            }
                          } catch (e) {
                            if (mounted) {
                              String errorMsg = e.toString();
                              if (errorMsg.contains('Exception:')) {
                                errorMsg = errorMsg.replaceAll('Exception:', '').trim();
                              }
                              setState(() {
                                _isLoading = false;
                                _errorMessage = errorMsg;
                              });
                            }
                          }
                        }
                      },
                child: _isLoading
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2)
                      )
                    : const Text('Save Changes'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
