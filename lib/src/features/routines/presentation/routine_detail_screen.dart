import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../exercises/domain/exercise.dart';
import '../data/routine_repository.dart';
import '../domain/routine.dart';
import 'providers/routine_providers.dart';
import '../../workout/presentation/providers/workout_providers.dart';

/// Routine detail screen showing exercises and allowing edits
class RoutineDetailScreen extends ConsumerWidget {
  final String routineId;

  const RoutineDetailScreen({
    super.key,
    required this.routineId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routineAsync = ref.watch(routineDetailProvider(routineId));

    return routineAsync.when(
      data: (routine) => _RoutineDetailContent(routine: routine),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
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
                'Failed to load routine',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(error.toString()),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.invalidate(routineDetailProvider(routineId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Main content for routine detail
class _RoutineDetailContent extends ConsumerWidget {
  final Routine routine;

  const _RoutineDetailContent({required this.routine});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(routine.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditDialog(context, ref),
            tooltip: 'Edit Routine',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'duplicate':
                  _duplicateRoutine(context, ref);
                  break;
                case 'delete':
                  _showDeleteDialog(context, ref);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy_outlined),
                    SizedBox(width: 8),
                    Text('Duplicate'),
                  ],
                ),
              ),
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
      body: routine.exercises.isEmpty
          ? _EmptyExercisesState(
              onAddExercise: () => _addExercise(context, ref),
            )
          : _ExerciseList(
              routine: routine,
              onAddExercise: () => _addExercise(context, ref),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startWorkout(context, ref),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start Workout'),
      ),
      bottomNavigationBar: routine.exercises.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton.icon(
                  onPressed: () => _addExercise(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Exercise'),
                ),
              ),
            ),
    );
  }

  Future<void> _addExercise(BuildContext context, WidgetRef ref) async {
    final exercise = await context.push<Exercise>('/exercises/pick');
    if (exercise != null) {
      try {
        final repo = ref.read(routineRepositoryProvider);
        await repo.addExercise(
          routineId: routine.id,
          exerciseId: exercise.id,
        );
        ref.invalidate(routineDetailProvider(routine.id));
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add exercise: $e')),
          );
        }
      }
    }
  }

  Future<void> _startWorkout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Start ${routine.name}?'),
        content: Text(
          'This will create a new workout with ${routine.exerciseCount} exercises.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref.read(activeWorkoutProvider.notifier).startWorkout(
            name: routine.name,
            routineId: routine.id,
          );

      if (success && context.mounted) {
        final workoutId = ref.read(activeWorkoutProvider).workout!.id;
        context.go('/workout/$workoutId');
      }
    }
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController(text: routine.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Routine'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Routine Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              Navigator.pop(context);
              try {
                final repo = ref.read(routineRepositoryProvider);
                await repo.updateRoutine(
                  id: routine.id,
                  name: nameController.text.trim(),
                );
                ref.invalidate(routineDetailProvider(routine.id));
                ref.invalidate(routineListProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _duplicateRoutine(BuildContext context, WidgetRef ref) async {
    try {
      final repo = ref.read(routineRepositoryProvider);
      final newRoutine = await repo.duplicateRoutine(routine.id);
      ref.invalidate(routineListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Routine duplicated')),
        );
        context.push('/routines/${newRoutine.id}');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to duplicate: $e')),
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Routine'),
        content: Text(
          'Are you sure you want to delete "${routine.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final repo = ref.read(routineRepositoryProvider);
                await repo.deleteRoutine(routine.id);
                ref.read(routineListProvider.notifier).removeRoutine(routine.id);
                if (context.mounted) {
                  context.pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Empty state when no exercises in routine
class _EmptyExercisesState extends StatelessWidget {
  final VoidCallback onAddExercise;

  const _EmptyExercisesState({required this.onAddExercise});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No exercises yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add exercises to build your routine',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddExercise,
              icon: const Icon(Icons.add),
              label: const Text('Add Exercise'),
            ),
          ],
        ),
      ),
    );
  }
}

/// List of exercises in the routine
class _ExerciseList extends ConsumerWidget {
  final Routine routine;
  final VoidCallback onAddExercise;

  const _ExerciseList({
    required this.routine,
    required this.onAddExercise,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: routine.exercises.length,
      onReorder: (oldIndex, newIndex) async {
        // Optimistic UI update
        final exerciseIds = routine.exercises.map((e) => e.id).toList();
        if (newIndex > oldIndex) newIndex--;
        final item = exerciseIds.removeAt(oldIndex);
        exerciseIds.insert(newIndex, item);

        try {
          final repo = ref.read(routineRepositoryProvider);
          await repo.reorderExercises(
            routineId: routine.id,
            exerciseIds: exerciseIds,
          );
          ref.invalidate(routineDetailProvider(routine.id));
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to reorder: $e')),
            );
          }
        }
      },
      itemBuilder: (context, index) {
        final exercise = routine.exercises[index];
        return _RoutineExerciseCard(
          key: ValueKey(exercise.id),
          routineExercise: exercise,
          routineId: routine.id,
          orderNumber: index + 1,
        );
      },
    );
  }
}

/// Card for a single exercise in the routine
class _RoutineExerciseCard extends ConsumerWidget {
  final RoutineExercise routineExercise;
  final String routineId;
  final int orderNumber;

  const _RoutineExerciseCard({
    super.key,
    required this.routineExercise,
    required this.routineId,
    required this.orderNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Drag handle
            Icon(
              Icons.drag_indicator,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),

            // Order number
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                '$orderNumber',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(width: 12),

            // Exercise info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routineExercise.exercise.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${routineExercise.targetSets} sets',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (routineExercise.targetRepsRange != null) ...[
                        Text(
                          ' • ${routineExercise.targetRepsRange}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                  if (routineExercise.notes != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      routineExercise.notes!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Delete button
            IconButton(
              icon: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: () => _confirmRemove(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Exercise'),
        content: Text(
          'Remove ${routineExercise.exercise.name} from this routine?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final repo = ref.read(routineRepositoryProvider);
                await repo.removeExercise(
                  routineId: routineId,
                  exerciseId: routineExercise.id,
                );
                ref.invalidate(routineDetailProvider(routineId));
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to remove: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
