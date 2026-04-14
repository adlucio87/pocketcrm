import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:pocketcrm/domain/models/company.dart';
import 'package:pocketcrm/presentation/shared/snackbar_helper.dart';

class CompanyPickerBottomSheet extends ConsumerStatefulWidget {
  const CompanyPickerBottomSheet({super.key});

  @override
  ConsumerState<CompanyPickerBottomSheet> createState() =>
      _CompanyPickerBottomSheetState();
}

class _CompanyPickerBottomSheetState
    extends ConsumerState<CompanyPickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim();
    });
    ref.read(companiesProvider.notifier).search(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    final companiesAsync = ref.watch(companiesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Company',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search companies...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Create New Company Button (if search has text)
              if (_searchQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: () => _createNewCompany(context),
                    icon: const Icon(Icons.add_business),
                    label: Text('Create "$_searchQuery"'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),

              const Divider(),

              // List of Companies
              Expanded(
                child: companiesAsync.when(
                  data: (companies) {
                    if (companies.isEmpty) {
                      return Center(
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'No companies found for "$_searchQuery"'
                              : 'No companies available',
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: companies.length,
                      itemBuilder: (context, index) {
                        final company = companies[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer,
                            child: Text(
                              company.name.isNotEmpty
                                  ? company.name[0].toUpperCase()
                                  : '?',
                            ),
                          ),
                          title: Text(company.name),
                          subtitle: company.domainName != null
                              ? Text(company.domainName!)
                              : null,
                          onTap: () {
                            Navigator.of(context).pop(company);
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => Center(
                    child: Text('Error: $error'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createNewCompany(BuildContext context) async {
    final name = _searchQuery;
    final navigator = Navigator.of(context);

    // Show a dialog to confirm creation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Company'),
        content: Text('Are you sure you want to create a new company named "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      final newCompany = await ref
          .read(companiesProvider.notifier)
          .addCompany(name: name);

      // Hide loading indicator
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        SnackbarHelper.showSuccess(context, 'Company "$name" created.');
        navigator.pop(newCompany);
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // hide loading
      if (mounted) {
        SnackbarHelper.showError(context, 'Error creating company: $e');
      }
    }
  }
}
