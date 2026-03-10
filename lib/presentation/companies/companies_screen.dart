import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:pocketcrm/core/di/auth_state.dart';
import 'package:pocketcrm/presentation/shared/linked_contacts_widget.dart';
import 'package:pocketcrm/presentation/shared/skeleton_loading.dart';
import 'package:pocketcrm/presentation/shared/empty_state_widget.dart';

class CompaniesScreen extends ConsumerWidget {
  const CompaniesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companiesAsync = ref.watch(companiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aziende'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
            tooltip: 'Logout / Reset',
          ),
        ],
      ),
      body: companiesAsync.when(
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
                    title: 'Nessuna azienda',
                    message: 'Non ci sono aziende nel database.',
                  ),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(companiesProvider.future),
            child: ListView.separated(
              itemCount: companies.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final company = companies[index];
                return ListTile(
                  onTap: () => context.push('/companies/${company.id}'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Hero(
                    tag: 'company-logo-${company.id}',
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: company.logoUrl != null
                          ? NetworkImage(company.logoUrl!)
                          : null,
                      child: company.logoUrl == null
                          ? const Icon(Icons.business, color: Colors.grey)
                          : null,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                  title: Text(
                    company.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      if (company.domainName != null)
                        Text(
                          company.domainName!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (company.industry != null) ...[
                            Icon(Icons.category, size: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                            const SizedBox(width: 4),
                            Text(company.industry!, style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(width: 12),
                          ],
                          if (company.employeesCount != null) ...[
                            Icon(Icons.people, size: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                            const SizedBox(width: 4),
                            Text('${company.employeesCount}', style: Theme.of(context).textTheme.bodySmall),
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
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                );
              },
            ),
          );
        },
        loading: () => const ListSkeleton(),
        error: (err, stack) => Center(child: Text('Errore: $err')),
      ),
    );
  }
}

