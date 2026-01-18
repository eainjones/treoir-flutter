import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../exercises/domain/exercise.dart';
import '../../domain/workout_exercise.dart';
import '../providers/workout_providers.dart';
import 'set_input_row.dart';

/// Card for an exercise in an active workout
class ActiveExerciseCard extends ConsumerStatefulWidget {
  final WorkoutExercise workoutExercise;
  final int exerciseIndex;

  const ActiveExerciseCard({
    super.key,
    required this.workoutExercise,
    required this.exerciseIndex,
  });

  @override
  ConsumerState<ActiveExerciseCard> createState() => _ActiveExerciseCardState();
}

class _ActiveExerciseCardState extends ConsumerState<ActiveExerciseCard> {
  bool _isExpanded = true;

  Future<void> _replaceExercise() async {
    final result = await context.push<Exercise>('/exercises/pick');
    if (result != null && mounted) {
      await ref.read(activeWorkoutProvider.notifier).replaceExercise(
            oldExerciseId: widget.workoutExercise.id,
            newExerciseId: result.id,
          );
    }
  }

  void _showExerciseOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.note_add_outlined),
              title: const Text('Add Note'),
              onTap: () {
                Navigator.pop(context);
                _showAddNoteDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_vert),
              title: const Text('Replace Exercise'),
              onTap: () {
                Navigator.pop(context);
                _replaceExercise();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Remove Exercise', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showRemoveConfirmation();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog() {
    final controller = TextEditingController(text: widget.workoutExercise.notes);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exercise Note'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Add a note...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(activeWorkoutProvider.notifier).updateExerciseNote(
                    exerciseId: widget.workoutExercise.id,
                    notes: controller.text,
                  );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showRemoveConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Exercise'),
        content: Text('Remove ${widget.workoutExercise.exercise.name} and all its sets?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(activeWorkoutProvider.notifier).removeExercise(
                    widget.workoutExercise.id,
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _addSet() async {
    // Add a new empty set
    await ref.read(activeWorkoutProvider.notifier).addSet(
          exerciseId: widget.workoutExercise.id,
          reps: 0,
          weightKg: 0,
        );
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.workoutExercise;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
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

                  // Exercise info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.exercise.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (exercise.notes != null)
                          Text(
                            exercise.notes!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  // Set count badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${exercise.completedSetsCount}/${exercise.sets.length}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Options menu
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: _showExerciseOptions,
                  ),

                  // Expand/collapse
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (_isExpanded) ...[
            const Divider(height: 1),

            // Previous performance hint
            if (exercise.sets.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Tap + to add your first set',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),

            // Sets header
            if (exercise.sets.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    const SizedBox(width: 48, child: Text('SET')),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'PREVIOUS',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    const SizedBox(
                      width: 80,
                      child: Text('WEIGHT', textAlign: TextAlign.center),
                    ),
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 60,
                      child: Text('REPS', textAlign: TextAlign.center),
                    ),
                    const SizedBox(width: 8),
                    const SizedBox(width: 48), // Checkbox space
                  ],
                ),
              ),

            // Sets list
            ...exercise.sets.asMap().entries.map((entry) {
              final index = entry.key;
              final set = entry.value;
              return SetInputRow(
                set: set,
                setNumber: index + 1,
                exerciseId: exercise.id,
              );
            }),

            // Add set button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addSet,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Set'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
