import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:pocketcrm/presentation/shared/linked_contacts_widget.dart';
import 'package:pocketcrm/presentation/shared/skeleton_loading.dart';
import 'package:pocketcrm/presentation/shared/empty_state_widget.dart';
import 'package:pocketcrm/presentation/shared/error_state_widget.dart';
import 'package:pocketcrm/core/utils/color_utils.dart';

import 'package:pocketcrm/presentation/shared/company_picker_bottom_sheet.dart';
import 'package:pocketcrm/domain/models/company.dart';
import 'package:pocketcrm/presentation/shared/snackbar_helper.dart';
import 'package:pocketcrm/core/utils/demo_utils.dart';
import 'package:pocketcrm/presentation/shared/swipe_action_wrapper.dart';
import 'package:pocketcrm/shared/widgets/constrained_content.dart';
import 'dart:async';

class CompaniesScreen extends ConsumerStatefulWidget {
  const CompaniesScreen({super.key});

  @override
  ConsumerState<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends ConsumerState<CompaniesScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(companiesProvider.notifier).search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final companiesAsync = ref.watch(companiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search companies...',
            prefixIcon: const Icon(Icons.search),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Colors.white,
          ),
          onChanged: _onSearchChanged,
        ),
        actions: const [],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!await DemoUtils.checkDemoAction(context, ref)) return;
          if (mounted) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => const AddCompanySheet(),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
      body: ConstrainedContent(child: companiesAsync.when(
        data: (companies) {
          if (companies.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => ref.refresh(companiesProvider.future),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: const EmptyStateWidget(
                    icon: Icons.business,
                    title: 'No companies',
                    message: 'There are no companies in the database.',
                  ),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(companiesProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: companies.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final company = companies[index];
                final bgColor = ColorUtils.avatarColor(company.name);
                return SwipeActionWrapper(
                  itemKey: ValueKey('company_${company.id}'),
                  confirmTitle: 'Delete company',
                  confirmMessage:
                      'Are you sure you want to delete ${company.name}?\nThis action cannot be undone.',
                  onDelete: () async {
                    if (!await DemoUtils.checkDemoAction(context, ref)) return;
                    try {
                      await ref
                          .read(companiesProvider.notifier)
                          .deleteCompany(company.id);
                    } catch (e) {
                      if (context.mounted) {
                        SnackbarHelper.showError(
                          context,
                          'Failed to delete company: ${e.toString().replaceAll('Exception: ', '')}',
                        );
                      }
                    }
                  },
                  onEdit: () async {
                    if (!await DemoUtils.checkDemoAction(context, ref)) return;
                    if (context.mounted) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) => EditCompanySheet(company: company),
                      );
                    }
                  },
                  child: Card(
                    child: ListTile(
                    onTap: () => context.push('/companies/${company.id}'),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    leading: Hero(
                      tag: 'company-logo-${company.id}',
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: bgColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          image: company.logoUrl != null && company.logoUrl!.isNotEmpty
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(company.logoUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: company.logoUrl == null || company.logoUrl!.isEmpty
                            ? Center(
                                child: Text(
                                  company.name.isNotEmpty ? company.name[0].toUpperCase() : '?',
                                  style: TextStyle(
                                    color: bgColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                    title: Text(
                      company.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        if (company.domainName != null)
                          Text(
                            company.domainName!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (company.industry != null) ...[
                              Icon(
                                Icons.category,
                                size: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                company.industry!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(width: 12),
                            ],
                            if (company.employeesCount != null) ...[
                              Icon(
                                Icons.people,
                                size: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${company.employeesCount}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinkedContactsWidget(
                          entityId: company.id,
                          type: LinkedContactType.company,
                          isCompact: true,
                        ),
                      ],
                    ),
                    trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                  ),
                ));
              },
            ),
          );
        },
        loading: () => const ListSkeleton(),
        error: (err, stack) => ErrorStateWidget(
          title: 'Loading error',
          message: err.toString().replaceAll('Exception: ', ''),
          onRetry: () => ref.invalidate(companiesProvider),
        ),
      )),
    );
  }
}

class AddCompanySheet extends ConsumerStatefulWidget {
  const AddCompanySheet({super.key});

  @override
  ConsumerState<AddCompanySheet> createState() => AddCompanySheetState();
}

class AddCompanySheetState extends ConsumerState<AddCompanySheet> {
  final _nameController = TextEditingController();
  final _domainController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _domainController.dispose();
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
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'New Company',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Company Name'),
                validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _domainController,
                decoration: const InputDecoration(
                  labelText: 'Domain or Website',
                  hintText: 'e.g. example.com',
                ),
                keyboardType: TextInputType.url,
                enabled: !_isLoading,
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
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 13,
                          ),
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
                        setState(() {
                          _errorMessage = null;
                        });
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });

                          final navigator = Navigator.of(context);

                          try {
                            await ref
                                .read(companiesProvider.notifier)
                                .addCompany(
                                  name: _nameController.text.trim(),
                                  domainName: _domainController.text.trim().isNotEmpty
                                      ? _domainController.text.trim()
                                      : null,
                                );

                            if (mounted) {
                              navigator.pop();
                              SnackbarHelper.showSuccess(
                                context,
                                'Company created successfully',
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              String errorMsg = e.toString();
                              if (errorMsg.contains('Exception:')) {
                                errorMsg = errorMsg
                                    .replaceAll('Exception:', '')
                                    .trim();
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
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Company'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class EditCompanySheet extends ConsumerStatefulWidget {
  final Company company;

  const EditCompanySheet({super.key, required this.company});

  @override
  ConsumerState<EditCompanySheet> createState() => EditCompanySheetState();
}

class EditCompanySheetState extends ConsumerState<EditCompanySheet> {
  late TextEditingController _nameController;
  late TextEditingController _domainController;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.company.name);
    _domainController = TextEditingController(text: widget.company.domainName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _domainController.dispose();
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
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Company',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Company Name'),
                validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _domainController,
                decoration: const InputDecoration(
                  labelText: 'Domain or Website',
                  hintText: 'e.g. example.com',
                ),
                keyboardType: TextInputType.url,
                enabled: !_isLoading,
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
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 13,
                          ),
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
                        setState(() {
                          _errorMessage = null;
                        });
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });

                          final navigator = Navigator.of(context);

                          try {
                            await ref
                                .read(companiesProvider.notifier)
                                .updateCompany(
                                  widget.company.id,
                                  name: _nameController.text.trim(),
                                  domainName: _domainController.text.trim(),
                                );

                            if (mounted) {
                              navigator.pop();
                              SnackbarHelper.showSuccess(
                                context,
                                'Company updated successfully',
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              String errorMsg = e.toString();
                              if (errorMsg.contains('Exception:')) {
                                errorMsg = errorMsg
                                    .replaceAll('Exception:', '')
                                    .trim();
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
                        child: CircularProgressIndicator(strokeWidth: 2),
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

