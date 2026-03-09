import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:pocketcrm/core/di/auth_state.dart';
import 'package:pocketcrm/domain/models/contact.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  bool _showCompleted = false;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);

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
              _showCompleted ? Icons.check_box : Icons.check_box_outline_blank,
            ),
            onPressed: () {
              setState(() {
                _showCompleted = !_showCompleted;
              });
              ref.read(tasksProvider.notifier).filterCompleted(_showCompleted);
            },
            tooltip: 'Filtra completati',
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(child: Text('Nessun task trovato.'));
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
                            .toggleTask(task.id, val);
                      }
                    },
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      decoration: task.completed == true
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.completed == true ? Colors.grey : null,
                    ),
                  ),
                  subtitle: Text(
                    task.dueAt != null
                        ? 'Scadenza: ${task.dueAt!.toLocal().toString().split(' ')[0]}'
                        : 'Nessuna scadenza',
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Errore: $err')),
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
              'Nuovo Task',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titolo',
                hintText: 'Cosa devi fare?',
              ),
              autofocus: true,
              validator: (v) =>
                  v?.isEmpty == true ? 'Inserisci un titolo' : null,
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
                    decoration: const InputDecoration(
                      labelText: 'Cerca e collega contatto',
                      hintText: 'Inizia a digitare il nome...',
                    ),
                  );
                },
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Errore contatti: $err'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await ref
                      .read(tasksProvider.notifier)
                      .addTask(
                        _titleController.text,
                        contactId: _selectedContactId,
                      );
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Crea Task'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
