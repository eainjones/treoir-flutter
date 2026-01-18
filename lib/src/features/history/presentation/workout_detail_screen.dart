import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../workout/data/workout_repository.dart';
import '../../workout/domain/workout.dart';
import '../../workout/domain/workout_exercise.dart';
import '../../workout/domain/exercise_set.dart';
import '../../workout/presentation/providers/workout_providers.dart';

/// Workout detail screen showing completed workout data
class WorkoutDetailScreen extends ConsumerWidget {
  final String workoutId;

  const WorkoutDetailScreen({
    super.key,
    required this.workoutId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutAsync = ref.watch(workoutDetailProvider(workoutId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: workoutAsync.when(
        data: (workout) => _WorkoutDetailContent(workout: workout),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
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
                  'Failed to load workout',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.invalidate(workoutDetailProvider(workoutId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: const Text('Are you sure you want to delete this workout? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Delete and go back
              final repo = ref.read(workoutRepositoryProvider);
              await repo.deleteWorkout(workoutId);
              ref.read(workoutListProvider.notifier).removeWorkout(workoutId);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Workout detail content
class _WorkoutDetailContent extends StatelessWidget {
  final Workout workout;

  const _WorkoutDetailContent({required this.workout});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMMEEEEd();
    final timeFormat = DateFormat.jm();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name ?? 'Workout',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dateFormat.format(workout.startedAt),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${timeFormat.format(workout.startedAt)} - ${workout.completedAt != null ? timeFormat.format(workout.completedAt!) : "In progress"}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        label: 'Duration',
                        value: workout.formattedDuration,
                        icon: Icons.timer_outlined,
                      ),
                      _StatColumn(
                        label: 'Exercises',
                        value: '${workout.exerciseCount}',
                        icon: Icons.fitness_center,
                      ),
                      _StatColumn(
                        label: 'Sets',
                        value: '${workout.totalSets}',
                        icon: Icons.repeat,
                      ),
                      _StatColumn(
                        label: 'Volume',
                        value: _formatVolume(workout.totalVolumeKg),
                        icon: Icons.scale,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Notes section
          if (workout.notes != null && workout.notes!.isNotEmpty) ...[
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(workout.notes!),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Exercises section
          Text(
            'Exercises',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          if (workout.exercises.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No exercises recorded',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            )
          else
            ...workout.exercises.map((exercise) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ExerciseCard(workoutExercise: exercise),
                )),
        ],
      ),
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}k kg';
    }
    return '${volume.toStringAsFixed(0)} kg';
  }
}

/// Stat column for summary
class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Exercise card showing sets
class _ExerciseCard extends StatelessWidget {
  final WorkoutExercise workoutExercise;

  const _ExerciseCard({required this.workoutExercise});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise name
            Text(
              workoutExercise.exercise.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (workoutExercise.notes != null) ...[
              const SizedBox(height: 4),
              Text(
                workoutExercise.notes!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),

            // Sets header
            Row(
              children: [
                SizedBox(width: 40, child: Text('Set', style: Theme.of(context).textTheme.labelSmall)),
                Expanded(child: Text('Weight', style: Theme.of(context).textTheme.labelSmall)),
                Expanded(child: Text('Reps', style: Theme.of(context).textTheme.labelSmall)),
                SizedBox(width: 40, child: Text('RPE', style: Theme.of(context).textTheme.labelSmall)),
              ],
            ),
            const Divider(),

            // Sets
            ...workoutExercise.sets.asMap().entries.map((entry) {
              final index = entry.key;
              final set = entry.value;
              return _SetRow(setNumber: index + 1, exerciseSet: set);
            }),

            // Summary
            if (workoutExercise.sets.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Best: ${workoutExercise.bestSet?.weightKg?.toStringAsFixed(1) ?? "-"} kg × ${workoutExercise.bestSet?.reps ?? "-"}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Single set row
class _SetRow extends StatelessWidget {
  final int setNumber;
  final ExerciseSet exerciseSet;

  const _SetRow({
    required this.setNumber,
    required this.exerciseSet,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = exerciseSet.isCompleted;
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isCompleted ? null : Theme.of(context).colorScheme.onSurfaceVariant,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Row(
              children: [
                Text('$setNumber', style: textStyle),
                if (exerciseSet.setTypeLabel.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    exerciseSet.setTypeLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: Text(
              exerciseSet.weightKg?.toStringAsFixed(1) ?? '-',
              style: textStyle,
            ),
          ),
          Expanded(
            child: Text(
              exerciseSet.reps?.toString() ?? '-',
              style: textStyle,
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              exerciseSet.rpe?.toString() ?? '-',
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }
}
