import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:pocketcrm/domain/models/company.dart';
import 'package:pocketcrm/domain/models/note.dart';
import 'package:pocketcrm/shared/widgets/block_note_renderer.dart';
import 'package:pocketcrm/presentation/shared/linked_contacts_widget.dart';
import 'package:pocketcrm/presentation/notes/edit_note_sheet.dart';
import 'package:pocketcrm/presentation/shared/skeleton_loading.dart';
import 'package:pocketcrm/presentation/shared/snackbar_helper.dart';

class CompanyDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const CompanyDetailScreen({super.key, required this.id});

  @override
  ConsumerState<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends ConsumerState<CompanyDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(companyDetailProvider(widget.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Company Details')),
      floatingActionButton: detailAsync.whenOrNull(
        data: (company) => FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => _AddCompanyNoteSheet(companyId: company.id),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('New Note'),
        ),
      ),
      body: detailAsync.when(
        data: (company) => _buildDetail(context, company),
        loading: () => const DetailSkeleton(),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, Company company) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: company.logoUrl != null
                ? NetworkImage(company.logoUrl!)
                : null,
            child: company.logoUrl == null
                ? const Icon(Icons.business, size: 40)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            company.name,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          if (company.domainName != null) ...[
            const SizedBox(height: 4),
            InkWell(
              onTap: () async {
                final url = Uri.parse('https://${company.domainName}');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: Text(
                company.domainName!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                if (company.industry != null)
                  ListTile(
                    leading: const Icon(Icons.category),
                    title: Text(company.industry!),
                    subtitle: const Text('Industry'),
                  ),
                if (company.employeesCount != null)
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: Text('${company.employeesCount}'),
                    subtitle: const Text('Employees'),
                  ),
                if (company.industry == null && company.employeesCount == null)
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('No additional details'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          LinkedContactsWidget(
            entityId: company.id,
            type: LinkedContactType.company,
          ),
          const SizedBox(height: 24),
          const Text(
            'Related Notes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          _CompanyNotesList(companyId: company.id),
        ],
      ),
    );
  }
}

class _CompanyNotesList extends ConsumerWidget {
  final String companyId;
  const _CompanyNotesList({required this.companyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(companyNotesProvider(companyId));

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
          itemBuilder: (context, index) => _NoteCard(note: notes[index], companyId: companyId),
        );
      },
      loading: () => const ListSkeleton(shrinkWrap: true),
      error: (err, stack) => Center(child: Text('Error loading notes: $err')),
    );
  }
}

// Reuse the same _NoteCard logic as ContactDetailScreen for consistency
class _NoteCard extends StatelessWidget {
  final Note note;
  final String? companyId;
  const _NoteCard({required this.note, this.companyId});

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
                          companyId: companyId,
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
// Add Note bottom sheet for Company
// ──────────────────────────────────────────────────────────────────────────────
class _AddCompanyNoteSheet extends ConsumerStatefulWidget {
  final String companyId;
  const _AddCompanyNoteSheet({required this.companyId});

  @override
  ConsumerState<_AddCompanyNoteSheet> createState() => _AddCompanyNoteSheetState();
}

class _AddCompanyNoteSheetState extends ConsumerState<_AddCompanyNoteSheet> {
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
      await ref.read(companyNotesProvider(widget.companyId).notifier).addNote(
            widget.companyId,
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
