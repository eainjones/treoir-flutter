import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/workout.dart';
import 'providers/workout_providers.dart';
import 'widgets/recent_workout_card.dart';
import 'widgets/start_workout_button.dart';

/// Workout home screen - main landing page
class WorkoutHomeScreen extends ConsumerWidget {
  const WorkoutHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeWorkoutState = ref.watch(activeWorkoutProvider);
    final recentWorkoutsAsync = ref.watch(recentWorkoutsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push(AppRoutes.history),
            tooltip: 'History',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(recentWorkoutsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Active workout banner
              if (activeWorkoutState.hasActiveWorkout)
                _ActiveWorkoutBanner(
                  workout: activeWorkoutState.workout!,
                  onTap: () {
                    context.push('/workout/${activeWorkoutState.workout!.id}');
                  },
                ),

              if (activeWorkoutState.hasActiveWorkout)
                const SizedBox(height: 24),

              // Start workout section
              Text(
                'Start Workout',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),

              // Quick start button
              StartWorkoutButton(
                label: 'Quick Start',
                subtitle: 'Start an empty workout',
                icon: Icons.play_arrow_rounded,
                onTap: activeWorkoutState.hasActiveWorkout
                    ? null
                    : () => _startQuickWorkout(context, ref),
              ),
              const SizedBox(height: 12),

              // From routine button
              StartWorkoutButton(
                label: 'From Routine',
                subtitle: 'Choose a saved routine',
                icon: Icons.list_alt_rounded,
                onTap: activeWorkoutState.hasActiveWorkout
                    ? null
                    : () => context.push(AppRoutes.routines),
              ),

              const SizedBox(height: 32),

              // Recent workouts section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Workouts',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.history),
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Recent workouts list
              recentWorkoutsAsync.when(
                data: (workouts) {
                  if (workouts.isEmpty) {
                    return _EmptyWorkoutsCard();
                  }
                  return Column(
                    children: workouts
                        .map((workout) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: RecentWorkoutCard(
                                workout: workout,
                                onTap: () {
                                  context.push('/history/${workout.id}');
                                },
                              ),
                            ))
                        .toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => _ErrorCard(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(recentWorkoutsProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startQuickWorkout(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(activeWorkoutProvider.notifier).startWorkout();
    if (success && context.mounted) {
      final workoutId = ref.read(activeWorkoutProvider).workout!.id;
      context.push('/workout/$workoutId');
    }
  }
}

/// Banner showing active workout
class _ActiveWorkoutBanner extends StatelessWidget {
  final Workout workout;
  final VoidCallback onTap;

  const _ActiveWorkoutBanner({
    required this.workout,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Workout in Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workout.name ?? 'Quick Workout',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state for workouts
class _EmptyWorkoutsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No workouts yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Start your first workout to see it here',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Error card with retry
class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load workouts',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
