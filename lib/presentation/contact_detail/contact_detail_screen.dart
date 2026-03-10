//
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:pocketcrm/domain/models/contact.dart';
import 'package:pocketcrm/domain/models/note.dart';
import 'package:pocketcrm/shared/widgets/block_note_renderer.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:pocketcrm/presentation/contacts/edit_contact_sheet.dart';
import 'package:pocketcrm/presentation/notes/edit_note_sheet.dart';
import 'package:pocketcrm/presentation/shared/skeleton_loading.dart';
import 'package:pocketcrm/presentation/shared/snackbar_helper.dart';

class ContactDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const ContactDetailScreen({super.key, required this.id});

  @override
  ConsumerState<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends ConsumerState<ContactDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(contactDetailProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Details'),
        actions: [
          detailAsync.whenOrNull(
            data: (contact) => IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit contact',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => EditContactSheet(contact: contact),
                );
              },
            ),
          ) ?? const SizedBox.shrink(),
        ],
      ),
      floatingActionButton: detailAsync.whenOrNull(
        data: (contact) => FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => _AddNoteSheet(contactId: contact.id),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('New Note'),
        ),
      ),
      body: detailAsync.when(
        data: (contact) => _buildDetail(context, contact),
        loading: () => const DetailSkeleton(),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, Contact contact) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: contact.avatarUrl != null
                ? NetworkImage(contact.avatarUrl!)
                : null,
            child: contact.avatarUrl == null
                ? Text(
                    contact.firstName.isNotEmpty ? contact.firstName[0] : '?',
                    style: const TextStyle(fontSize: 40),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            '${contact.firstName} ${contact.lastName}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          if (contact.companyName != null)
            Text(
              contact.companyName!,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          const SizedBox(height: 32),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text(
                    contact.email ?? 'No email',
                    style: TextStyle(
                      color: contact.email != null ? Colors.blue : null,
                      decoration: contact.email != null ? TextDecoration.underline : null,
                    ),
                  ),
                  onTap: contact.email != null
                      ? () async {
                          final uri = Uri.parse('mailto:${contact.email}');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Unable to open email client')),
                              );
                            }
                          }
                        }
                      : null,
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(
                    contact.phone ?? 'No phone',
                    style: TextStyle(
                      color: contact.phone != null ? Colors.blue : null,
                      decoration: contact.phone != null ? TextDecoration.underline : null,
                    ),
                  ),
                  onTap: contact.phone != null
                      ? () async {
                          if (kIsWeb || (!Platform.isIOS && !Platform.isAndroid)) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Calls are only supported on mobile devices')),
                              );
                            }
                            return;
                          }
                          final uri = Uri.parse('tel:${contact.phone}');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Unable to start the call')),
                              );
                            }
                          }
                        }
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              if (await fc.FlutterContacts.permissions.request(fc.PermissionType.write) == fc.PermissionStatus.granted) {
                final emails = contact.email != null ? [fc.Email(address: contact.email!)] : <fc.Email>[];
                final phones = contact.phone != null ? [fc.Phone(number: contact.phone!)] : <fc.Phone>[];
                final newContact = fc.Contact(
                  name: fc.Name(first: contact.firstName, last: contact.lastName),
                  emails: emails,
                  phones: phones,
                );
                await fc.FlutterContacts.native.showCreator(contact: newContact);
              }
            },
            icon: const Icon(Icons.save_alt),
            label: const Text('Save to Contacts'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Related Notes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          _NotesList(contactId: contact.id),
        ],
      ),
    );
  }
}

class _NotesList extends ConsumerWidget {
  final String contactId;
  const _NotesList({required this.contactId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(contactNotesProvider(contactId));

    return notesAsync.when(
      data: (notes) {
        if (notes.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No notes present'),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: notes.length,
          itemBuilder: (context, index) => _NoteCard(note: notes[index], contactId: contactId),
        );
      },
      loading: () => const ListSkeleton(shrinkWrap: true),
      error: (err, stack) => Center(child: Text('Error loading notes: $err')),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final String? contactId;
  const _NoteCard({required this.note, this.contactId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openFullNote(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview compatta — altezza limitata
              LimitedBox(
                maxHeight: 120,
                child: IgnorePointer(
                  child: BlockNoteRenderer(json: note.body, compact: true),
                ),
              ),
              if (note.createdAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.createdAt!.toLocal().toString().split('.')[0],
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Icon(Icons.open_in_full, size: 14, color: Colors.grey.shade400),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openFullNote(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.4,
        maxChildSize: 1.0,
        expand: false,
        builder: (ctx, scrollController) => Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header con data e chiudi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      note.createdAt != null
                          ? note.createdAt!.toLocal().toString().split('.')[0]
                          : 'Note',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    tooltip: 'Edit note',
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => EditNoteSheet(
                          note: note,
                          contactId: contactId,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Contenuto completo
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: BlockNoteRenderer(json: note.body),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Add Note bottom sheet
// ──────────────────────────────────────────────────────────────────────────────
class _AddNoteSheet extends ConsumerStatefulWidget {
  final String contactId;
  const _AddNoteSheet({required this.contactId});

  @override
  ConsumerState<_AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends ConsumerState<_AddNoteSheet> {
  final _bodyController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _bodyController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(contactNotesProvider(widget.contactId).notifier).addNote(
            widget.contactId,
            text,
          );
      if (mounted) {
        Navigator.of(context).pop();
        SnackbarHelper.showSuccess(context, 'Note added successfully');
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('New Note', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            TextField(
              controller: _bodyController,
              enabled: !_isLoading,
              maxLines: 6,
              minLines: 3,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Note text',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save Note'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
