import 'package:flutter_test/flutter_test.dart';
import 'package:treoir/src/features/exercises/domain/exercise.dart';
import 'package:treoir/src/features/workout/domain/exercise_set.dart';
import 'package:treoir/src/features/workout/domain/workout.dart';
import 'package:treoir/src/features/workout/domain/workout_exercise.dart';

void main() {
  group('Workout', () {
    final testDate = DateTime(2026, 1, 15, 9, 30);

    group('fromJson', () {
      test('parses complete JSON correctly', () {
        final json = {
          'id': 'workout-123',
          'name': 'Push Day',
          'notes': 'Great session',
          'startedAt': '2026-01-15T09:30:00Z',
          'completedAt': '2026-01-15T10:45:00Z',
          'durationSeconds': 4500,
          'totalSets': 18,
          'totalReps': 156,
          'totalVolumeKg': 8450.0,
          'exerciseCount': 5,
          'exercises': [],
          'syncStatus': 'synced',
          'status': 'completed',
        };

        final workout = Workout.fromJson(json);

        expect(workout.id, 'workout-123');
        expect(workout.name, 'Push Day');
        expect(workout.notes, 'Great session');
        expect(workout.totalSets, 18);
        expect(workout.totalReps, 156);
        expect(workout.totalVolumeKg, 8450.0);
        expect(workout.exerciseCount, 5);
        expect(workout.syncStatus, 'synced');
        expect(workout.status, 'completed');
      });

      test('handles minimal JSON with defaults', () {
        final json = {
          'id': 'workout-123',
          'startedAt': '2026-01-15T09:30:00Z',
        };

        final workout = Workout.fromJson(json);

        expect(workout.id, 'workout-123');
        expect(workout.name, isNull);
        expect(workout.totalSets, 0);
        expect(workout.totalReps, 0);
        expect(workout.totalVolumeKg, 0.0);
        expect(workout.exercises, isEmpty);
        expect(workout.syncStatus, 'pending');
        expect(workout.status, 'active');
      });
    });

    group('isActive', () {
      test('returns true when no completedAt and status is active', () {
        final workout = Workout(
          id: 'w-1',
          startedAt: testDate,
          status: 'active',
        );
        expect(workout.isActive, true);
      });

      test('returns false when completedAt is set', () {
        final workout = Workout(
          id: 'w-1',
          startedAt: testDate,
          completedAt: testDate.add(const Duration(hours: 1)),
          status: 'active',
        );
        expect(workout.isActive, false);
      });

      test('returns false when status is not active', () {
        final workout = Workout(
          id: 'w-1',
          startedAt: testDate,
          status: 'completed',
        );
        expect(workout.isActive, false);
      });
    });

    group('isCompleted', () {
      test('returns true when completedAt is set', () {
        final workout = Workout(
          id: 'w-1',
          startedAt: testDate,
          completedAt: testDate.add(const Duration(hours: 1)),
        );
        expect(workout.isCompleted, true);
      });

      test('returns true when status is completed', () {
        final workout = Workout(
          id: 'w-1',
          startedAt: testDate,
          status: 'completed',
        );
        expect(workout.isCompleted, true);
      });

      test('returns false when active with no completedAt', () {
        final workout = Workout(
          id: 'w-1',
          startedAt: testDate,
          status: 'active',
        );
        expect(workout.isCompleted, false);
      });
    });

    group('formattedDuration', () {
      test('formats hours and minutes', () {
        final workout = Workout(
          id: 'w-1',
          startedAt: testDate,
          durationSeconds: 4500, // 1h 15m
        );
        expect(workout.formattedDuration, '1h 15m');
      });

      test('formats minutes and seconds', () {
        final workout = Workout(
          id: 'w-1',
          startedAt: testDate,
          durationSeconds: 330, // 5m 30s
        );
        expect(workout.formattedDuration, '5m 30s');
      });
    });

    group('recalculateTotals', () {
      test('calculates totals from completed sets', () {
        const exercise = Exercise(
          id: 'ex-1',
          name: 'Bench Press',
          category: 'strength',
          primaryMuscle: 'chest',
          equipment: 'barbell',
        );

        final workout = Workout(
          id: 'w-1',
          startedAt: testDate,
          exercises: [
            WorkoutExercise(
              id: 'we-1',
              orderIndex: 0,
              exercise: exercise,
              sets: [
                const ExerciseSet(
                  id: 's-1',
                  orderIndex: 0,
                  reps: 10,
                  weightKg: 80.0,
                  isCompleted: true,
                ),
                const ExerciseSet(
                  id: 's-2',
                  orderIndex: 1,
                  reps: 8,
                  weightKg: 85.0,
                  isCompleted: true,
                ),
                const ExerciseSet(
                  id: 's-3',
                  orderIndex: 2,
                  reps: 6,
                  weightKg: 90.0,
                  isCompleted: false, // not completed
                ),
              ],
            ),
          ],
        );

        final recalculated = workout.recalculateTotals();

        expect(recalculated.totalSets, 2); // only completed sets
        expect(recalculated.totalReps, 18); // 10 + 8
        expect(recalculated.totalVolumeKg, 1480.0); // (80*10) + (85*8)
        expect(recalculated.exerciseCount, 1);
      });

      test('handles empty exercises', () {
        final workout = Workout(
          id: 'w-1',
          startedAt: testDate,
          exercises: [],
        );

        final recalculated = workout.recalculateTotals();

        expect(recalculated.totalSets, 0);
        expect(recalculated.totalReps, 0);
        expect(recalculated.totalVolumeKg, 0.0);
        expect(recalculated.exerciseCount, 0);
      });
    });
  });
}
