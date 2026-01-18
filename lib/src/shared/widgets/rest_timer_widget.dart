import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/rest_timer_provider.dart';
import '../../core/constants/app_constants.dart';

/// Rest timer widget for display during workouts
class RestTimerWidget extends ConsumerWidget {
  const RestTimerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(restTimerProvider);

    if (timerState.isIdle) {
      return _IdleTimerButton(
        onStart: () => ref.read(restTimerProvider.notifier).start(),
      );
    }

    return _ActiveTimerDisplay(timerState: timerState);
  }
}

/// Button shown when timer is idle
class _IdleTimerButton extends StatelessWidget {
  final VoidCallback onStart;

  const _IdleTimerButton({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onStart,
      icon: const Icon(Icons.timer_outlined),
      label: const Text('Rest Timer'),
    );
  }
}

/// Active timer display
class _ActiveTimerDisplay extends ConsumerWidget {
  final RestTimerState timerState;

  const _ActiveTimerDisplay({required this.timerState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: timerState.isFinished
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Timer display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Time
                Text(
                  timerState.formattedTime,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: timerState.progress,
                minHeight: 8,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),

            const SizedBox(height: 16),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // -15s button
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: timerState.remainingSeconds > 15
                      ? () => ref.read(restTimerProvider.notifier).addTime(-15)
                      : null,
                  tooltip: '-15s',
                ),

                const SizedBox(width: 8),

                // Play/Pause button
                if (timerState.isFinished)
                  FilledButton.icon(
                    onPressed: () => ref.read(restTimerProvider.notifier).reset(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  )
                else if (timerState.isRunning)
                  FilledButton.icon(
                    onPressed: () => ref.read(restTimerProvider.notifier).pause(),
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                  )
                else
                  FilledButton.icon(
                    onPressed: () => ref.read(restTimerProvider.notifier).resume(),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Resume'),
                  ),

                const SizedBox(width: 8),

                // +15s button
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => ref.read(restTimerProvider.notifier).addTime(15),
                  tooltip: '+15s',
                ),
              ],
            ),

            // Skip button
            if (!timerState.isFinished)
              TextButton(
                onPressed: () => ref.read(restTimerProvider.notifier).skip(),
                child: const Text('Skip'),
              ),
          ],
        ),
      ),
    );
  }
}

/// Compact rest timer for bottom sheet
class RestTimerBottomSheet extends ConsumerWidget {
  const RestTimerBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const RestTimerBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Rest Timer',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            // Timer
            const RestTimerWidget(),
            const SizedBox(height: 24),

            // Quick time buttons
            Text(
              'Quick Start',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: AppConstants.restTimerOptions.map((seconds) {
                return ActionChip(
                  label: Text('${seconds}s'),
                  onPressed: () {
                    ref.read(restTimerProvider.notifier).start(durationSeconds: seconds);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Mini timer FAB for active workout
class RestTimerFAB extends ConsumerWidget {
  const RestTimerFAB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(restTimerProvider);

    if (timerState.isIdle) {
      return FloatingActionButton(
        mini: true,
        onPressed: () => RestTimerBottomSheet.show(context),
        child: const Icon(Icons.timer_outlined),
      );
    }

    // Show compact timer when active
    return FloatingActionButton.extended(
      onPressed: () => RestTimerBottomSheet.show(context),
      icon: timerState.isFinished
          ? const Icon(Icons.check_circle)
          : timerState.isRunning
              ? const Icon(Icons.pause)
              : const Icon(Icons.play_arrow),
      label: Text(timerState.formattedTime),
      backgroundColor: timerState.isFinished
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
    );
  }
}
