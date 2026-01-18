import 'package:flutter_test/flutter_test.dart';
import 'package:treoir/src/features/workout/domain/exercise_set.dart';

void main() {
  group('ExerciseSet', () {
    group('fromJson', () {
      test('parses complete JSON correctly', () {
        final json = {
          'id': 'set-123',
          'orderIndex': 0,
          'reps': 8,
          'weightKg': 80.0,
          'rpe': 7,
          'setType': 'working',
          'isCompleted': true,
          'completedAt': '2026-01-15T09:35:00Z',
        };

        final set = ExerciseSet.fromJson(json);

        expect(set.id, 'set-123');
        expect(set.orderIndex, 0);
        expect(set.reps, 8);
        expect(set.weightKg, 80.0);
        expect(set.rpe, 7);
        expect(set.setType, 'working');
        expect(set.isCompleted, true);
        expect(set.completedAt, isNotNull);
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'set-123',
          'orderIndex': 1,
        };

        final set = ExerciseSet.fromJson(json);

        expect(set.id, 'set-123');
        expect(set.orderIndex, 1);
        expect(set.reps, isNull);
        expect(set.weightKg, isNull);
        expect(set.rpe, isNull);
        expect(set.setType, 'working'); // default
        expect(set.isCompleted, false); // default
        expect(set.completedAt, isNull);
      });
    });

    group('toJson', () {
      test('serializes correctly', () {
        const set = ExerciseSet(
          id: 'set-123',
          orderIndex: 0,
          reps: 10,
          weightKg: 100.0,
          rpe: 8,
          setType: 'warmup',
          isCompleted: true,
        );

        final json = set.toJson();

        expect(json['id'], 'set-123');
        expect(json['orderIndex'], 0);
        expect(json['reps'], 10);
        expect(json['weightKg'], 100.0);
        expect(json['rpe'], 8);
        expect(json['setType'], 'warmup');
        expect(json['isCompleted'], true);
      });
    });

    group('displayWeight', () {
      test('returns dash when weightKg is null', () {
        const set = ExerciseSet(id: 'set-1', orderIndex: 0);
        expect(set.displayWeight(), '-');
      });

      test('displays kg correctly', () {
        const set = ExerciseSet(id: 'set-1', orderIndex: 0, weightKg: 80.5);
        expect(set.displayWeight(), '80.5 kg');
      });

      test('displays lbs correctly', () {
        const set = ExerciseSet(id: 'set-1', orderIndex: 0, weightKg: 80.0);
        final display = set.displayWeight(useImperial: true);
        expect(display, contains('lbs'));
        // 80 kg * 2.20462 = 176.37 lbs
        expect(display, contains('176.4'));
      });
    });

    group('setTypeLabel', () {
      test('returns empty string for working sets', () {
        const set = ExerciseSet(id: 'set-1', orderIndex: 0, setType: 'working');
        expect(set.setTypeLabel, '');
      });

      test('returns W for warmup', () {
        const set = ExerciseSet(id: 'set-1', orderIndex: 0, setType: 'warmup');
        expect(set.setTypeLabel, 'W');
      });

      test('returns D for drop', () {
        const set = ExerciseSet(id: 'set-1', orderIndex: 0, setType: 'drop');
        expect(set.setTypeLabel, 'D');
      });

      test('returns F for failure', () {
        const set = ExerciseSet(id: 'set-1', orderIndex: 0, setType: 'failure');
        expect(set.setTypeLabel, 'F');
      });

      test('returns A for amrap', () {
        const set = ExerciseSet(id: 'set-1', orderIndex: 0, setType: 'amrap');
        expect(set.setTypeLabel, 'A');
      });
    });
  });

  group('SetType', () {
    test('value returns correct string', () {
      expect(SetType.working.value, 'working');
      expect(SetType.warmup.value, 'warmup');
      expect(SetType.drop.value, 'drop');
      expect(SetType.failure.value, 'failure');
      expect(SetType.amrap.value, 'amrap');
    });

    test('label returns correct display string', () {
      expect(SetType.working.label, 'Working');
      expect(SetType.warmup.label, 'Warm-up');
      expect(SetType.drop.label, 'Drop');
      expect(SetType.failure.label, 'Failure');
      expect(SetType.amrap.label, 'AMRAP');
    });
  });
}
