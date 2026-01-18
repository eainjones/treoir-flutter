import 'package:flutter_test/flutter_test.dart';
import 'package:treoir/src/features/exercises/domain/exercise.dart';
import 'package:treoir/src/features/workout/domain/exercise_set.dart';
import 'package:treoir/src/features/workout/domain/workout_exercise.dart';

void main() {
  const testExercise = Exercise(
    id: 'ex-1',
    name: 'Barbell Bench Press',
    category: 'strength',
    primaryMuscle: 'chest',
    equipment: 'barbell',
  );

  group('WorkoutExercise', () {
    group('fromJson', () {
      test('parses complete JSON correctly', () {
        final json = {
          'id': 'we-123',
          'orderIndex': 0,
          'notes': 'Focus on squeeze',
          'exercise': {
            'id': 'ex-1',
            'name': 'Bench Press',
            'category': 'strength',
            'primaryMuscle': 'chest',
            'equipment': 'barbell',
          },
          'sets': [
            {
              'id': 's-1',
              'orderIndex': 0,
              'reps': 10,
              'weightKg': 80.0,
              'isCompleted': true,
            }
          ],
        };

        final workoutExercise = WorkoutExercise.fromJson(json);

        expect(workoutExercise.id, 'we-123');
        expect(workoutExercise.orderIndex, 0);
        expect(workoutExercise.notes, 'Focus on squeeze');
        expect(workoutExercise.exercise.name, 'Bench Press');
        expect(workoutExercise.sets.length, 1);
      });
    });

    group('completedSetsCount', () {
      test('counts only completed sets', () {
        final workoutExercise = WorkoutExercise(
          id: 'we-1',
          orderIndex: 0,
          exercise: testExercise,
          sets: [
            const ExerciseSet(id: 's-1', orderIndex: 0, isCompleted: true),
            const ExerciseSet(id: 's-2', orderIndex: 1, isCompleted: true),
            const ExerciseSet(id: 's-3', orderIndex: 2, isCompleted: false),
          ],
        );

        expect(workoutExercise.completedSetsCount, 2);
      });

      test('returns 0 when no sets completed', () {
        final workoutExercise = WorkoutExercise(
          id: 'we-1',
          orderIndex: 0,
          exercise: testExercise,
          sets: [
            const ExerciseSet(id: 's-1', orderIndex: 0, isCompleted: false),
            const ExerciseSet(id: 's-2', orderIndex: 1, isCompleted: false),
          ],
        );

        expect(workoutExercise.completedSetsCount, 0);
      });

      test('returns 0 when no sets', () {
        final workoutExercise = WorkoutExercise(
          id: 'we-1',
          orderIndex: 0,
          exercise: testExercise,
          sets: [],
        );

        expect(workoutExercise.completedSetsCount, 0);
      });
    });

    group('totalVolume', () {
      test('calculates volume from completed sets', () {
        final workoutExercise = WorkoutExercise(
          id: 'we-1',
          orderIndex: 0,
          exercise: testExercise,
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
              isCompleted: false, // not counted
            ),
          ],
        );

        // (80 * 10) + (85 * 8) = 800 + 680 = 1480
        expect(workoutExercise.totalVolume, 1480.0);
      });

      test('returns 0 when no completed sets', () {
        final workoutExercise = WorkoutExercise(
          id: 'we-1',
          orderIndex: 0,
          exercise: testExercise,
          sets: [
            const ExerciseSet(
              id: 's-1',
              orderIndex: 0,
              reps: 10,
              weightKg: 80.0,
              isCompleted: false,
            ),
          ],
        );

        expect(workoutExercise.totalVolume, 0.0);
      });

      test('handles null weight and reps', () {
        final workoutExercise = WorkoutExercise(
          id: 'we-1',
          orderIndex: 0,
          exercise: testExercise,
          sets: [
            const ExerciseSet(
              id: 's-1',
              orderIndex: 0,
              isCompleted: true,
              // no weight or reps
            ),
          ],
        );

        expect(workoutExercise.totalVolume, 0.0);
      });
    });

    group('bestSet', () {
      test('returns set with highest weight', () {
        final workoutExercise = WorkoutExercise(
          id: 'we-1',
          orderIndex: 0,
          exercise: testExercise,
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
              weightKg: 90.0,
              isCompleted: true,
            ),
            const ExerciseSet(
              id: 's-3',
              orderIndex: 2,
              reps: 6,
              weightKg: 85.0,
              isCompleted: true,
            ),
          ],
        );

        final best = workoutExercise.bestSet;
        expect(best, isNotNull);
        expect(best!.id, 's-2');
        expect(best.weightKg, 90.0);
      });

      test('returns null when no completed sets', () {
        final workoutExercise = WorkoutExercise(
          id: 'we-1',
          orderIndex: 0,
          exercise: testExercise,
          sets: [
            const ExerciseSet(
              id: 's-1',
              orderIndex: 0,
              reps: 10,
              weightKg: 80.0,
              isCompleted: false,
            ),
          ],
        );

        expect(workoutExercise.bestSet, isNull);
      });

      test('returns null when no sets have weight', () {
        final workoutExercise = WorkoutExercise(
          id: 'we-1',
          orderIndex: 0,
          exercise: testExercise,
          sets: [
            const ExerciseSet(
              id: 's-1',
              orderIndex: 0,
              reps: 10,
              isCompleted: true,
            ),
          ],
        );

        expect(workoutExercise.bestSet, isNull);
      });

      test('returns null when empty', () {
        final workoutExercise = WorkoutExercise(
          id: 'we-1',
          orderIndex: 0,
          exercise: testExercise,
          sets: [],
        );

        expect(workoutExercise.bestSet, isNull);
      });
    });
  });
}
