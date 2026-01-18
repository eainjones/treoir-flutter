import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/workout.dart';

/// Card displaying a recent workout summary
class RecentWorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onTap;

  const RecentWorkoutCard({
    super.key,
    required this.workout,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.MMMd();

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      workout.name ?? 'Workout',
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    dateFormat.format(workout.startedAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Stats row
              Row(
                children: [
                  _StatChip(
                    icon: Icons.timer_outlined,
                    value: workout.formattedDuration,
                  ),
                  const SizedBox(width: 16),
                  _StatChip(
                    icon: Icons.fitness_center,
                    value: '${workout.exerciseCount} exercises',
                  ),
                  const SizedBox(width: 16),
                  _StatChip(
                    icon: Icons.repeat,
                    value: '${workout.totalSets} sets',
                  ),
                ],
              ),

              // Volume
              if (workout.totalVolumeKg > 0) ...[
                const SizedBox(height: 8),
                Text(
                  '${_formatVolume(workout.totalVolumeKg)} kg total volume',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}k';
    }
    return volume.toStringAsFixed(0);
  }
}

/// Small stat chip with icon and value
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;

  const _StatChip({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
