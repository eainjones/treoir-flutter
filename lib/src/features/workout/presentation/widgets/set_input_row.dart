import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/rest_timer_provider.dart';
import '../../../settings/presentation/settings_screen.dart';
import '../../domain/exercise_set.dart';
import '../providers/workout_providers.dart';

/// Input row for a single set
class SetInputRow extends ConsumerStatefulWidget {
  final ExerciseSet set;
  final int setNumber;
  final String exerciseId;
  final String? previousPerformance;
  final double? previousWeight;
  final int? previousReps;

  const SetInputRow({
    super.key,
    required this.set,
    required this.setNumber,
    required this.exerciseId,
    this.previousPerformance,
    this.previousWeight,
    this.previousReps,
  });

  @override
  ConsumerState<SetInputRow> createState() => _SetInputRowState();
}

class _SetInputRowState extends ConsumerState<SetInputRow> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  late FocusNode _weightFocus;
  late FocusNode _repsFocus;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.set.weightKg?.toStringAsFixed(1) ?? '',
    );
    _repsController = TextEditingController(
      text: widget.set.reps?.toString() ?? '',
    );
    _weightFocus = FocusNode();
    _repsFocus = FocusNode();

    // Listen to focus changes for auto-save
    _weightFocus.addListener(_onWeightFocusChange);
    _repsFocus.addListener(_onRepsFocusChange);
  }

  @override
  void didUpdateWidget(SetInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controllers if set data changed externally
    if (oldWidget.set.weightKg != widget.set.weightKg) {
      _weightController.text = widget.set.weightKg?.toStringAsFixed(1) ?? '';
    }
    if (oldWidget.set.reps != widget.set.reps) {
      _repsController.text = widget.set.reps?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _weightFocus.removeListener(_onWeightFocusChange);
    _repsFocus.removeListener(_onRepsFocusChange);
    _weightController.dispose();
    _repsController.dispose();
    _weightFocus.dispose();
    _repsFocus.dispose();
    super.dispose();
  }

  void _onWeightFocusChange() {
    if (!_weightFocus.hasFocus) {
      _saveWeight();
    }
  }

  void _onRepsFocusChange() {
    if (!_repsFocus.hasFocus) {
      _saveReps();
    }
  }

  Future<void> _saveWeight() async {
    final text = _weightController.text.trim();
    if (text.isEmpty) return;

    final weight = double.tryParse(text);
    if (weight == null) return;

    // Convert from lbs to kg if using imperial
    final useImperial = ref.read(useImperialUnitsProvider);
    final weightKg = useImperial ? weight / 2.20462 : weight;

    if (weightKg != widget.set.weightKg) {
      await ref.read(activeWorkoutProvider.notifier).updateSet(
            exerciseId: widget.exerciseId,
            setId: widget.set.id,
            weightKg: weightKg,
          );
    }
  }

  Future<void> _saveReps() async {
    final text = _repsController.text.trim();
    if (text.isEmpty) return;

    final reps = int.tryParse(text);
    if (reps == null) return;

    if (reps != widget.set.reps) {
      await ref.read(activeWorkoutProvider.notifier).updateSet(
            exerciseId: widget.exerciseId,
            setId: widget.set.id,
            reps: reps,
          );
    }
  }

  Future<void> _toggleCompleted() async {
    HapticFeedback.lightImpact();

    final newCompleted = !widget.set.isCompleted;

    // Save current values first if not empty
    final weightText = _weightController.text.trim();
    final repsText = _repsController.text.trim();
    final weight = double.tryParse(weightText);
    final reps = int.tryParse(repsText);

    final useImperial = ref.read(useImperialUnitsProvider);
    final weightKg = weight != null
        ? (useImperial ? weight / 2.20462 : weight)
        : widget.set.weightKg;

    await ref.read(activeWorkoutProvider.notifier).updateSet(
          exerciseId: widget.exerciseId,
          setId: widget.set.id,
          weightKg: weightKg,
          reps: reps ?? widget.set.reps,
          isCompleted: newCompleted,
        );

    // Start rest timer when completing a set
    if (newCompleted) {
      ref.read(restTimerProvider.notifier).start();
    }
  }

  void _showSetTypeSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Set Type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...SetType.values.map((type) {
              final isSelected = type.value == widget.set.setType;
              return ListTile(
                title: Text(type.label),
                leading: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? Theme.of(context).colorScheme.primary : null,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _updateSetType(type);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _updateSetType(SetType type) async {
    await ref.read(activeWorkoutProvider.notifier).updateSet(
          exerciseId: widget.exerciseId,
          setId: widget.set.id,
          setType: type.value,
        );
  }

  void _showRPESelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Rate of Perceived Exertion',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'How hard did this set feel?',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List.generate(10, (index) {
                  final rpe = index + 1;
                  final isSelected = widget.set.rpe == rpe;
                  return ChoiceChip(
                    label: Text('$rpe'),
                    selected: isSelected,
                    onSelected: (selected) {
                      Navigator.pop(context);
                      _updateRPE(rpe);
                    },
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Easy', style: Theme.of(context).textTheme.labelSmall),
                  Text('Max effort', style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
            // Clear RPE option
            if (widget.set.rpe != null)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _clearRPE();
                },
                child: const Text('Clear RPE'),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _updateRPE(int rpe) async {
    await ref.read(activeWorkoutProvider.notifier).updateSet(
          exerciseId: widget.exerciseId,
          setId: widget.set.id,
          rpe: rpe,
        );
  }

  Future<void> _clearRPE() async {
    // Note: API needs to support null RPE - for now we'll set to 0 as a "clear" value
    // In practice the API should handle null to clear the value
    await ref.read(activeWorkoutProvider.notifier).updateSet(
          exerciseId: widget.exerciseId,
          setId: widget.set.id,
          rpe: 0,
        );
  }

  void _copyPreviousValues() {
    if (widget.previousWeight == null && widget.previousReps == null) {
      return;
    }

    HapticFeedback.selectionClick();

    final useImperial = ref.read(useImperialUnitsProvider);

    if (widget.previousWeight != null) {
      final displayWeight = useImperial
          ? widget.previousWeight! * 2.20462
          : widget.previousWeight!;
      _weightController.text = displayWeight.toStringAsFixed(1);
    }

    if (widget.previousReps != null) {
      _repsController.text = widget.previousReps.toString();
    }

    // Save the copied values
    _saveWeight();
    _saveReps();
  }

  @override
  Widget build(BuildContext context) {
    final useImperial = ref.watch(useImperialUnitsProvider);
    final isCompleted = widget.set.isCompleted;
    final setTypeLabel = widget.set.setTypeLabel;

    return Dismissible(
      key: ValueKey('set-${widget.set.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Set'),
            content: const Text('Are you sure you want to delete this set?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        ref.read(activeWorkoutProvider.notifier).deleteSet(
              exerciseId: widget.exerciseId,
              setId: widget.set.id,
            );
      },
      child: Container(
        color: isCompleted
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Set number and type
              SizedBox(
                width: 48,
                child: GestureDetector(
                  onTap: _showSetTypeSelector,
                  child: Row(
                    children: [
                      Text(
                        '${widget.setNumber}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (setTypeLabel.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          setTypeLabel,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Previous performance (tappable to copy)
              Expanded(
                child: GestureDetector(
                  onTap: _copyPreviousValues,
                  child: Text(
                    widget.previousPerformance ?? '-',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          decoration: widget.previousPerformance != null
                              ? TextDecoration.underline
                              : null,
                        ),
                  ),
                ),
              ),

              // Weight input
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _weightController,
                  focusNode: _weightFocus,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: useImperial ? 'lbs' : 'kg',
                    hintStyle: Theme.of(context).textTheme.bodySmall,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  onSubmitted: (_) => _repsFocus.requestFocus(),
                ),
              ),
              const SizedBox(width: 8),

              // Reps input
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _repsController,
                  focusNode: _repsFocus,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'reps',
                    hintStyle: Theme.of(context).textTheme.bodySmall,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onSubmitted: (_) => _toggleCompleted(),
                ),
              ),
              const SizedBox(width: 4),

              // RPE button (only show if set has RPE or is completed)
              SizedBox(
                width: 36,
                child: GestureDetector(
                  onTap: _showRPESelector,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    child: widget.set.rpe != null && widget.set.rpe! > 0
                        ? Text(
                            '@${widget.set.rpe}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          )
                        : Icon(
                            Icons.speed_outlined,
                            size: 18,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                  ),
                ),
              ),

              // Complete checkbox
              SizedBox(
                width: 44,
                child: IconButton(
                  icon: Icon(
                    isCompleted ? Icons.check_circle : Icons.circle_outlined,
                    color: isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: _toggleCompleted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Weight input with increment/decrement buttons
class WeightInputField extends StatelessWidget {
  final double? value;
  final bool useImperial;
  final ValueChanged<double> onChanged;

  const WeightInputField({
    super.key,
    this.value,
    required this.useImperial,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value ?? 0.0;
    final increment = useImperial ? 5.0 : 2.5; // 5 lbs or 2.5 kg

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove, size: 18),
          onPressed: displayValue > 0
              ? () => onChanged((displayValue - increment).clamp(0, 9999))
              : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        SizedBox(
          width: 60,
          child: Text(
            '${displayValue.toStringAsFixed(1)} ${useImperial ? 'lbs' : 'kg'}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add, size: 18),
          onPressed: () => onChanged(displayValue + increment),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}

/// Reps input with increment/decrement buttons
class RepsInputField extends StatelessWidget {
  final int? value;
  final ValueChanged<int> onChanged;

  const RepsInputField({
    super.key,
    this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value ?? 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove, size: 18),
          onPressed: displayValue > 0
              ? () => onChanged((displayValue - 1).clamp(0, 999))
              : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        SizedBox(
          width: 40,
          child: Text(
            '$displayValue',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add, size: 18),
          onPressed: () => onChanged(displayValue + 1),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}
