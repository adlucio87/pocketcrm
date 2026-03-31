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

class CompaniesScreen extends ConsumerWidget {
  const CompaniesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companiesAsync = ref.watch(companiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Companies'), actions: const []),
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
                return Card(
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
                );
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
      ),
    );
  }
}
