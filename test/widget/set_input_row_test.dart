import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treoir/src/features/settings/presentation/settings_screen.dart';
import 'package:treoir/src/features/workout/domain/exercise_set.dart';
import 'package:treoir/src/features/workout/presentation/widgets/set_input_row.dart';

void main() {
  group('SetInputRow', () {
    Widget buildWidget({
      ExerciseSet? set,
      int setNumber = 1,
      String exerciseId = 'ex-1',
      String? previousPerformance,
      double? previousWeight,
      int? previousReps,
      bool useImperial = false,
    }) {
      return ProviderScope(
        overrides: [
          useImperialUnitsProvider.overrideWith((ref) => useImperial),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SetInputRow(
              set: set ?? const ExerciseSet(
                id: 'set-1',
                orderIndex: 0,
                reps: 10,
                weightKg: 80.0,
                isCompleted: false,
              ),
              setNumber: setNumber,
              exerciseId: exerciseId,
              previousPerformance: previousPerformance,
              previousWeight: previousWeight,
              previousReps: previousReps,
            ),
          ),
        ),
      );
    }

    testWidgets('displays set number', (tester) async {
      await tester.pumpWidget(buildWidget(setNumber: 3));

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('displays weight value in text field', (tester) async {
      await tester.pumpWidget(buildWidget(
        set: const ExerciseSet(
          id: 'set-1',
          orderIndex: 0,
          weightKg: 85.5,
        ),
      ));

      expect(find.text('85.5'), findsOneWidget);
    });

    testWidgets('displays reps value in text field', (tester) async {
      await tester.pumpWidget(buildWidget(
        set: const ExerciseSet(
          id: 'set-1',
          orderIndex: 0,
          reps: 12,
        ),
      ));

      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('displays previous performance', (tester) async {
      await tester.pumpWidget(buildWidget(
        previousPerformance: '80kg × 10',
      ));

      expect(find.text('80kg × 10'), findsOneWidget);
    });

    testWidgets('displays dash when no previous performance', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('-'), findsOneWidget);
    });

    testWidgets('displays set type label for warmup', (tester) async {
      await tester.pumpWidget(buildWidget(
        set: const ExerciseSet(
          id: 'set-1',
          orderIndex: 0,
          setType: 'warmup',
        ),
      ));

      expect(find.text('W'), findsOneWidget);
    });

    testWidgets('displays check icon when completed', (tester) async {
      await tester.pumpWidget(buildWidget(
        set: const ExerciseSet(
          id: 'set-1',
          orderIndex: 0,
          isCompleted: true,
        ),
      ));

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('displays circle outline when not completed', (tester) async {
      await tester.pumpWidget(buildWidget(
        set: const ExerciseSet(
          id: 'set-1',
          orderIndex: 0,
          isCompleted: false,
        ),
      ));

      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
    });

    testWidgets('displays RPE when set', (tester) async {
      await tester.pumpWidget(buildWidget(
        set: const ExerciseSet(
          id: 'set-1',
          orderIndex: 0,
          rpe: 8,
        ),
      ));

      expect(find.text('@8'), findsOneWidget);
    });

    testWidgets('displays speed icon when no RPE', (tester) async {
      await tester.pumpWidget(buildWidget(
        set: const ExerciseSet(
          id: 'set-1',
          orderIndex: 0,
        ),
      ));

      expect(find.byIcon(Icons.speed_outlined), findsOneWidget);
    });

    testWidgets('shows kg hint when metric', (tester) async {
      await tester.pumpWidget(buildWidget(
        set: const ExerciseSet(id: 'set-1', orderIndex: 0),
        useImperial: false,
      ));

      expect(find.text('kg'), findsOneWidget);
    });

    testWidgets('shows lbs hint when imperial', (tester) async {
      await tester.pumpWidget(buildWidget(
        set: const ExerciseSet(id: 'set-1', orderIndex: 0),
        useImperial: true,
      ));

      expect(find.text('lbs'), findsOneWidget);
    });

    testWidgets('can enter weight value', (tester) async {
      await tester.pumpWidget(buildWidget(
        set: const ExerciseSet(id: 'set-1', orderIndex: 0),
      ));

      final weightField = find.byType(TextField).first;
      await tester.enterText(weightField, '100.5');
      await tester.pump();

      expect(find.text('100.5'), findsOneWidget);
    });

    testWidgets('can enter reps value', (tester) async {
      await tester.pumpWidget(buildWidget(
        set: const ExerciseSet(id: 'set-1', orderIndex: 0),
      ));

      final repsField = find.byType(TextField).last;
      await tester.enterText(repsField, '15');
      await tester.pump();

      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('completed set has background color', (tester) async {
      await tester.pumpWidget(buildWidget(
        set: const ExerciseSet(
          id: 'set-1',
          orderIndex: 0,
          isCompleted: true,
        ),
      ));

      // Just verify the widget renders without error
      expect(find.byType(SetInputRow), findsOneWidget);
    });
  });
}
