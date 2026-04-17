import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:pocketcrm/domain/models/company.dart';
import 'package:pocketcrm/presentation/shared/linked_contacts_widget.dart';
import 'package:pocketcrm/presentation/shared/note_card.dart';
import 'package:pocketcrm/presentation/shared/skeleton_loading.dart';
import 'package:pocketcrm/presentation/shared/snackbar_helper.dart';
import 'package:pocketcrm/presentation/shared/error_state_widget.dart';
import 'package:pocketcrm/core/utils/demo_utils.dart';
import 'package:pocketcrm/presentation/shared/dialog_helper.dart';
import 'package:pocketcrm/presentation/companies/companies_screen.dart';
import 'package:pocketcrm/shared/widgets/constrained_content.dart';

class CompanyDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const CompanyDetailScreen({super.key, required this.id});

  @override
  ConsumerState<CompanyDetailScreen> createState() =>
      _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends ConsumerState<CompanyDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(companyDetailProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Details'),
        actions: [
          if (detailAsync.hasValue)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit company',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => EditCompanySheet(company: detailAsync.value!),
                );
              },
            ),
          if (detailAsync.hasValue)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete company',
              onPressed: () async {
                if (!await DemoUtils.checkDemoAction(context, ref)) return;

                final confirm = await DialogHelper.showDeleteConfirmDialog(
                  context: context,
                  title: 'Delete company',
                  message:
                      'Are you sure you want to delete ${detailAsync.value!.name}?\nThis action cannot be undone.',
                );

                if (confirm && context.mounted) {
                  try {
                    await ref
                        .read(companiesProvider.notifier)
                        .deleteCompany(widget.id);

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      SnackbarHelper.showSuccess(context, 'Company deleted');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      SnackbarHelper.showError(
                        context,
                        'Error during deletion',
                      );
                    }
                  }
                }
              },
            ),
        ],
      ),
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
        error: (err, stack) => ErrorStateWidget(
          title: 'Error loading details',
          message: err.toString().replaceAll('Exception: ', ''),
          onRetry: () => ref.invalidate(companyDetailProvider(widget.id)),
        ),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, Company company) {
    return ConstrainedContent(
      child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: company.logoUrl != null
                ? CachedNetworkImageProvider(company.logoUrl!)
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
          itemBuilder: (context, index) =>
              NoteCard(note: notes[index], companyId: companyId),
        );
      },
      loading: () => const ListSkeleton(shrinkWrap: true),
      error: (err, stack) => Center(child: Text('Error loading notes: $err')),
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
  ConsumerState<_AddCompanyNoteSheet> createState() =>
      _AddCompanyNoteSheetState();
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
      await ref
          .read(companyNotesProvider(widget.companyId).notifier)
          .addNote(widget.companyId, text);
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
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Note'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
