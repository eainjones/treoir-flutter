import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../workout/domain/workout.dart';
import '../../workout/presentation/providers/workout_providers.dart';

/// Workout history screen with paginated list
class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(workoutListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutsAsync = ref.watch(workoutListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(workoutListProvider.notifier).refresh();
        },
        child: workoutsAsync.when(
          data: (workouts) {
            if (workouts.isEmpty) {
              return _EmptyState();
            }

            // Group workouts by month
            final grouped = _groupByMonth(workouts);

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: grouped.length + 1, // +1 for loading indicator
              itemBuilder: (context, index) {
                if (index == grouped.length) {
                  // Loading indicator at bottom
                  final notifier = ref.read(workoutListProvider.notifier);
                  if (notifier.hasMore) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const SizedBox.shrink();
                }

                final entry = grouped.entries.elementAt(index);
                return _MonthSection(
                  month: entry.key,
                  workouts: entry.value,
                  onWorkoutTap: (workout) {
                    context.push('/history/${workout.id}');
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _ErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(workoutListProvider),
          ),
        ),
      ),
    );
  }

  Map<String, List<Workout>> _groupByMonth(List<Workout> workouts) {
    final Map<String, List<Workout>> grouped = {};
    final monthFormat = DateFormat.yMMMM();

    for (final workout in workouts) {
      final key = monthFormat.format(workout.startedAt);
      grouped.putIfAbsent(key, () => []).add(workout);
    }

    return grouped;
  }
}

/// Month section with header and workout cards
class _MonthSection extends StatelessWidget {
  final String month;
  final List<Workout> workouts;
  final void Function(Workout) onWorkoutTap;

  const _MonthSection({
    required this.month,
    required this.workouts,
    required this.onWorkoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            month,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...workouts.map((workout) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _HistoryWorkoutCard(
                workout: workout,
                onTap: () => onWorkoutTap(workout),
              ),
            )),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// Workout card for history list
class _HistoryWorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback onTap;

  const _HistoryWorkoutCard({
    required this.workout,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Date column
              SizedBox(
                width: 48,
                child: Column(
                  children: [
                    Text(
                      DateFormat.d().format(workout.startedAt),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      DateFormat.E().format(workout.startedAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 1,
                height: 40,
                color: Theme.of(context).dividerColor,
              ),
              const SizedBox(width: 16),

              // Details column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name ?? 'Workout',
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _MiniStat(Icons.timer_outlined, workout.formattedDuration),
                        const SizedBox(width: 12),
                        _MiniStat(Icons.fitness_center, '${workout.exerciseCount}'),
                        const SizedBox(width: 12),
                        _MiniStat(Icons.repeat, '${workout.totalSets}'),
                      ],
                    ),
                  ],
                ),
              ),

              // Chevron
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;

  const _MiniStat(this.icon, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 2),
        Text(value, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No workout history',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Your completed workouts will appear here',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load history',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
