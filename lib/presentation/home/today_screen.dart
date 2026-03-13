import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pocketcrm/core/di/providers.dart';
import 'package:pocketcrm/presentation/home/today_provider.dart';
import 'package:pocketcrm/presentation/home/widgets/task_today_card.dart';
import 'package:pocketcrm/presentation/home/widgets/recent_contacts_row.dart';
import 'package:pocketcrm/presentation/home/widgets/section_header.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayState = ref.watch(todayNotifierProvider);

    return Scaffold(
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 3,
        childPadding: const EdgeInsets.all(5),
        spaceBetweenChildren: 4,
        tooltip: 'Aggiungi',
        heroTag: 'speed-dial-hero-tag',
        elevation: 8.0,
        animationCurve: Curves.elasticInOut,
        isOpenOnStart: false,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.person_add),
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
            label: 'Nuovo contatto',
            onTap: () => context.push('/contacts/create'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.add_task),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            label: 'Nuovo task rapido',
            onTap: () => context.push('/tasks/create'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(todayNotifierProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 120.0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
                title: Consumer(
                  builder: (context, ref, child) {
                    final userNameAsync = ref.watch(currentUserNameProvider);
                    final userName = userNameAsync.valueOrNull ?? 'Utente';

                    final now = DateTime.now();
                    final hour = now.hour;
                    String greeting = "Buongiorno 👋";
                    if (hour >= 12 && hour < 18) {
                      greeting = "Buon pomeriggio 👋";
                    } else if (hour >= 18 && hour < 24) {
                      greeting = "Buonasera 👋";
                    } else if (hour >= 0 && hour < 5) {
                      greeting = "Ancora sveglio? 👋";
                    }

                    final dateFormat = DateFormat('EEEE, d MMMM y', 'it_IT');
                    final dateString = dateFormat.format(now);
                    // Capitalize first letter of day
                    final formattedDate = dateString.replaceFirst(dateString[0], dateString[0].toUpperCase());

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          greeting,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formattedDate,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (userName.isNotEmpty)
                          Text(
                            userName,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            todayState.when(
              data: (data) {
                final hasOverdue = data.overdueTasks.isNotEmpty;
                final hasToday = data.todayTasks.isNotEmpty;
                final hasTomorrow = data.tomorrowTasks.isNotEmpty;
                final hasRecent = data.recentContacts.isNotEmpty;

                if (!hasOverdue && !hasToday && !hasTomorrow) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (hasRecent) ...[
                          const SectionHeader(title: "Recenti"),
                          RecentContactsRow(contacts: data.recentContacts),
                          const Spacer(),
                        ],
                        const Text("🎉", style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 16),
                        Text(
                          "Tutto in ordine!",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Nessun task in scadenza oggi",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.push('/tasks/create'),
                          child: const Text("Aggiungi task"),
                        ),
                        if (hasRecent) const Spacer(flex: 2),
                      ],
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildListDelegate([
                    if (hasOverdue) ...[
                      SectionHeader(
                        title: "Scaduti",
                        count: data.overdueTasks.length,
                        countColor: Theme.of(context).colorScheme.error,
                      ),
                      ...data.overdueTasks.map((t) => TaskTodayCard(task: t, isOverdue: true)),
                    ],

                    SectionHeader(
                      title: "Oggi",
                      count: data.todayTasks.length,
                    ),
                    if (hasToday)
                      ...data.todayTasks.map((t) => TaskTodayCard(task: t))
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text("Nessun task per oggi 🎉", style: Theme.of(context).textTheme.bodyMedium),
                      ),

                    if (hasTomorrow) ...[
                      const SectionHeader(title: "Domani"),
                      ...data.tomorrowTasks.take(3).map((t) => Opacity(
                        opacity: 0.7,
                        child: TaskTodayCard(task: t),
                      )),
                      if (data.tomorrowTasks.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 8),
                          child: Text("e altri ${data.tomorrowTasks.length - 3}...", style: Theme.of(context).textTheme.bodySmall),
                        ),
                    ],

                    if (hasRecent) ...[
                      const SectionHeader(title: "Recenti"),
                      RecentContactsRow(contacts: data.recentContacts),
                    ],

                    const SizedBox(height: 80), // Padding for FAB
                  ]),
                );
              },
              loading: () => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    highlightColor: Theme.of(context).colorScheme.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 100, height: 20, color: Colors.white, margin: const EdgeInsets.only(top: 20, bottom: 8)),
                        Container(height: 70, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.symmetric(vertical: 4)),
                        Container(height: 70, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.symmetric(vertical: 4)),

                        Container(width: 100, height: 20, color: Colors.white, margin: const EdgeInsets.only(top: 30, bottom: 8)),
                        Row(
                          children: List.generate(4, (index) => Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              error: (err, stack) => SliverToBoxAdapter(
                child: Center(child: Text('Errore: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
