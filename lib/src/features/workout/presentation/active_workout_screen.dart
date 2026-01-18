import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../exercises/domain/exercise.dart';
import '../domain/workout_exercise.dart';
import 'providers/workout_providers.dart';
import 'widgets/active_exercise_card.dart';

/// Active workout screen for logging exercises and sets
class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final String workoutId;

  const ActiveWorkoutScreen({
    super.key,
    required this.workoutId,
  });

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  Timer? _elapsedTimer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadWorkout();
  }

  void _loadWorkout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(activeWorkoutProvider);
      if (state.workout?.id != widget.workoutId) {
        ref.read(activeWorkoutProvider.notifier).loadWorkout(widget.workoutId);
      }
      _startElapsedTimer();
    });
  }

  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        final state = ref.read(activeWorkoutProvider);
        if (state.workout != null) {
          setState(() {
            _elapsed = DateTime.now().difference(state.workout!.startedAt);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _addExercise() async {
    final result = await context.push<Exercise>('/exercises/pick');
    if (result != null && mounted) {
      await ref.read(activeWorkoutProvider.notifier).addExercise(result.id);
    }
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      builder: (context) => _FinishWorkoutDialog(
        onFinish: (notes) async {
          Navigator.pop(context);
          final success = await ref.read(activeWorkoutProvider.notifier).completeWorkout(notes: notes);
          if (success && mounted) {
            context.go('/');
          }
        },
        onDiscard: () async {
          Navigator.pop(context);
          final confirmed = await _showDiscardConfirmation();
          if (confirmed && mounted) {
            await ref.read(activeWorkoutProvider.notifier).discardWorkout();
            if (mounted) context.go('/');
          }
        },
      ),
    );
  }

  Future<bool> _showDiscardConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard Workout?'),
            content: const Text('This will permanently delete this workout. This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Discard'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final activeState = ref.watch(activeWorkoutProvider);
    final workout = activeState.workout;

    if (activeState.isLoading && workout == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (workout == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load workout'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showFinishDialog();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showFinishDialog,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workout.name ?? 'Workout',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                _formatDuration(_elapsed),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _showFinishDialog,
              child: const Text('Finish'),
            ),
          ],
        ),
        body: workout.exercises.isEmpty
            ? _EmptyExerciseState(onAddExercise: _addExercise)
            : _ExerciseList(
                exercises: workout.exercises,
                onAddExercise: _addExercise,
              ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _addExercise,
              icon: const Icon(Icons.add),
              label: const Text('Add Exercise'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Empty state when no exercises added
class _EmptyExerciseState extends StatelessWidget {
  final VoidCallback onAddExercise;

  const _EmptyExerciseState({required this.onAddExercise});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
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
              'Add your first exercise to start logging',
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

/// List of exercises in the workout
class _ExerciseList extends ConsumerWidget {
  final List<WorkoutExercise> exercises;
  final VoidCallback onAddExercise;

  const _ExerciseList({
    required this.exercises,
    required this.onAddExercise,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exercises.length,
      onReorder: (oldIndex, newIndex) {
        // Adjust for removal before insertion
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }

        // Create reordered list of exercise IDs
        final exerciseIds = exercises.map((e) => e.id).toList();
        final movedId = exerciseIds.removeAt(oldIndex);
        exerciseIds.insert(newIndex, movedId);

        ref.read(activeWorkoutProvider.notifier).reorderExercises(exerciseIds);
      },
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return Padding(
          key: ValueKey(exercise.id),
          padding: const EdgeInsets.only(bottom: 16),
          child: ActiveExerciseCard(
            workoutExercise: exercise,
            exerciseIndex: index,
          ),
        );
      },
    );
  }
}

/// Finish workout dialog
class _FinishWorkoutDialog extends StatefulWidget {
  final void Function(String?) onFinish;
  final VoidCallback onDiscard;

  const _FinishWorkoutDialog({
    required this.onFinish,
    required this.onDiscard,
  });

  @override
  State<_FinishWorkoutDialog> createState() => _FinishWorkoutDialogState();
}

class _FinishWorkoutDialogState extends State<_FinishWorkoutDialog> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Finish Workout'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Add any notes about this workout (optional):'),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              hintText: 'Workout notes...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onDiscard,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Discard'),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => widget.onFinish(
            _notesController.text.isEmpty ? null : _notesController.text,
          ),
          child: const Text('Finish'),
        ),
      ],
    );
  }
}
