import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:treoir/src/features/exercises/domain/exercise.dart';
import 'package:treoir/src/features/routines/data/routine_repository.dart';
import 'package:treoir/src/features/routines/domain/routine.dart';
import 'package:treoir/src/features/routines/presentation/providers/routine_providers.dart';
import 'package:treoir/src/features/routines/presentation/routine_detail_screen.dart';

// Mock classes
class MockRoutineRepository extends Mock implements RoutineRepository {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockRoutineRepository mockRoutineRepository;

  setUpAll(() {
    registerFallbackValue(const Routine(id: '', name: ''));
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    mockRoutineRepository = MockRoutineRepository();
  });

  /// Create sample exercise for testing
  Exercise createSampleExercise({
    String id = 'exercise-1',
    String name = 'Bench Press',
  }) {
    return Exercise(
      id: id,
      name: name,
      category: 'strength',
      primaryMuscle: 'chest',
      equipment: 'barbell',
    );
  }

  /// Create sample routine exercise for testing
  RoutineExercise createSampleRoutineExercise({
    String id = 're-1',
    int orderIndex = 0,
    String exerciseName = 'Bench Press',
    int targetSets = 3,
    String? targetRepsRange = '8-12',
    String? notes,
  }) {
    return RoutineExercise(
      id: id,
      orderIndex: orderIndex,
      exercise: createSampleExercise(id: 'ex-$id', name: exerciseName),
      targetSets: targetSets,
      targetRepsRange: targetRepsRange,
      notes: notes,
    );
  }

  /// Create sample routine for testing
  Routine createSampleRoutine({
    String id = 'routine-1',
    String name = 'Push Day',
    int exerciseCount = 3,
    int? estimatedDuration = 45,
    List<RoutineExercise>? exercises,
  }) {
    return Routine(
      id: id,
      name: name,
      exerciseCount: exerciseCount,
      estimatedDuration: estimatedDuration,
      exercises: exercises ??
          [
            createSampleRoutineExercise(
              id: 're-1',
              orderIndex: 0,
              exerciseName: 'Bench Press',
              targetSets: 4,
              targetRepsRange: '6-8',
            ),
            createSampleRoutineExercise(
              id: 're-2',
              orderIndex: 1,
              exerciseName: 'Overhead Press',
              targetSets: 3,
              targetRepsRange: '8-10',
            ),
            createSampleRoutineExercise(
              id: 're-3',
              orderIndex: 2,
              exerciseName: 'Tricep Pushdown',
              targetSets: 3,
              targetRepsRange: '12-15',
              notes: 'Focus on squeeze at bottom',
            ),
          ],
    );
  }

  /// Helper to build test widget with ProviderScope
  Widget buildTestWidget({
    String routineId = 'routine-1',
    List<Override> overrides = const [],
    GoRouter? router,
  }) {
    final testRouter = router ??
        GoRouter(
          initialLocation: '/routines/$routineId',
          routes: [
            GoRoute(
              path: '/routines',
              builder: (context, state) => const Scaffold(
                body: Text('Routine List'),
              ),
            ),
            GoRoute(
              path: '/routines/:id',
              builder: (context, state) => RoutineDetailScreen(
                routineId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: '/exercises/pick',
              builder: (context, state) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.pop(
                    context,
                    createSampleExercise(id: 'new-ex', name: 'New Exercise'),
                  ),
                  child: const Text('Pick Exercise'),
                ),
              ),
            ),
            GoRoute(
              path: '/workout/:id',
              builder: (context, state) => Scaffold(
                body: Text('Workout: ${state.pathParameters['id']}'),
              ),
            ),
          ],
        );

    return ProviderScope(
      overrides: [
        routineRepositoryProvider.overrideWithValue(mockRoutineRepository),
        ...overrides,
      ],
      child: MaterialApp.router(
        routerConfig: testRouter,
      ),
    );
  }

  group('RoutineDetailScreen', () {
    group('Loading State', () {
      testWidgets('shows loading indicator while fetching routine',
          (tester) async {
        // Arrange - use a completer to control when the response completes
        final completer = Completer<Routine>();
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) => completer.future);

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Loading...'), findsOneWidget);

        // Complete the future to avoid pending timer issues
        completer.complete(createSampleRoutine());
        await tester.pumpAndSettle();
      });
    });

    group('Routine Information Display', () {
      testWidgets('shows routine name in app bar', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => createSampleRoutine(name: 'Leg Day'));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Leg Day'), findsOneWidget);
      });

      testWidgets('lists exercises with names', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => createSampleRoutine());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Bench Press'), findsOneWidget);
        expect(find.text('Overhead Press'), findsOneWidget);
        expect(find.text('Tricep Pushdown'), findsOneWidget);
      });

      testWidgets('shows target sets for each exercise', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => createSampleRoutine());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('4 sets'), findsOneWidget);
        expect(find.text('3 sets'), findsNWidgets(2)); // Overhead + Tricep
      });

      testWidgets('shows target reps range for exercises', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => createSampleRoutine());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert - look for the reps text with bullet separator
        expect(find.textContaining('6-8'), findsOneWidget);
        expect(find.textContaining('8-10'), findsOneWidget);
        expect(find.textContaining('12-15'), findsOneWidget);
      });

      testWidgets('shows exercise notes when available', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => createSampleRoutine());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Focus on squeeze at bottom'), findsOneWidget);
      });

      testWidgets('shows exercise order numbers', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => createSampleRoutine());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert - order numbers should be displayed
        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      });
    });

    group('Empty Exercises State', () {
      testWidgets('shows empty state when routine has no exercises',
          (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any())).thenAnswer(
          (_) async => createSampleRoutine(exercises: [], exerciseCount: 0),
        );

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('No exercises yet'), findsOneWidget);
        expect(
            find.text('Add exercises to build your routine'), findsOneWidget);
        expect(find.byIcon(Icons.fitness_center_outlined), findsOneWidget);
      });

      testWidgets('empty state has Add Exercise button', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any())).thenAnswer(
          (_) async => createSampleRoutine(exercises: [], exerciseCount: 0),
        );

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Add Exercise'), findsOneWidget);
      });
    });

    group('Start Workout Button', () {
      testWidgets('shows Start Workout FAB', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => createSampleRoutine());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.text('Start Workout'), findsOneWidget);
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      });

      testWidgets('Start Workout button shows confirmation dialog',
          (tester) async {
        // Arrange
        final routine = createSampleRoutine(name: 'Push Day', exerciseCount: 3);
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => routine);

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Tap start workout
        await tester.tap(find.text('Start Workout'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Start Push Day?'), findsOneWidget);
        expect(
          find.text('This will create a new workout with 3 exercises.'),
          findsOneWidget,
        );
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Start'), findsOneWidget);
      });

      testWidgets('Cancel dismisses start workout dialog', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => createSampleRoutine());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Start Workout'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Assert - dialog should be dismissed
        expect(find.text('Start Push Day?'), findsNothing);
      });
    });

    group('Delete Routine', () {
      testWidgets('shows delete option in popup menu', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => createSampleRoutine());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Open popup menu
        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Delete'), findsOneWidget);
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      });

      testWidgets('delete button shows confirmation dialog', (tester) async {
        // Arrange
        final routine = createSampleRoutine(name: 'My Routine');
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => routine);

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Open popup menu and tap delete
        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        // Assert - confirmation dialog
        expect(find.text('Delete Routine'), findsOneWidget);
        expect(
          find.text(
              'Are you sure you want to delete "My Routine"? This cannot be undone.'),
          findsOneWidget,
        );
        expect(find.text('Cancel'), findsOneWidget);
        // Find delete button in dialog (there's also the menu item)
        expect(find.widgetWithText(TextButton, 'Delete'), findsOneWidget);
      });

      testWidgets('cancel dismisses delete confirmation', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => createSampleRoutine());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Assert - dialog dismissed, still on detail screen
        expect(find.text('Delete Routine'), findsNothing);
        expect(find.text('Push Day'), findsOneWidget);
      });
    });

    group('Edit Routine', () {
      testWidgets('shows edit button in app bar', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => createSampleRoutine());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      });

      testWidgets('edit button opens edit dialog', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => createSampleRoutine(name: 'Push Day'));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Edit Routine'), findsOneWidget);
        expect(find.text('Routine Name'), findsOneWidget);
        expect(find.text('Save'), findsOneWidget);
      });

      testWidgets('edit dialog pre-fills current routine name', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => createSampleRoutine(name: 'Push Day'));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        // Assert - text field should contain current name
        final textField = find.byType(TextField);
        expect(textField, findsOneWidget);

        final textFieldWidget = tester.widget<TextField>(textField);
        expect(textFieldWidget.controller?.text, 'Push Day');
      });

      testWidgets('cancel dismisses edit dialog', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => createSampleRoutine());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Edit Routine'), findsNothing);
      });
    });

    group('Duplicate Routine', () {
      testWidgets('shows duplicate option in popup menu', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => createSampleRoutine());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Duplicate'), findsOneWidget);
        expect(find.byIcon(Icons.copy_outlined), findsOneWidget);
      });
    });

    group('Add Exercise', () {
      testWidgets('shows Add Exercise button when exercises exist',
          (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => createSampleRoutine());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert - button in bottom nav
        expect(find.text('Add Exercise'), findsOneWidget);
      });
    });

    group('Remove Exercise', () {
      testWidgets('shows remove button on exercise cards', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => createSampleRoutine());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert - close icon for removing exercises
        expect(find.byIcon(Icons.close), findsNWidgets(3));
      });

      testWidgets('remove button shows confirmation dialog', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => createSampleRoutine());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Tap first remove button
        await tester.tap(find.byIcon(Icons.close).first);
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Remove Exercise'), findsOneWidget);
        expect(
          find.text('Remove Bench Press from this routine?'),
          findsOneWidget,
        );
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Remove'), findsOneWidget);
      });

      testWidgets('cancel dismisses remove confirmation', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => createSampleRoutine());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.close).first);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Assert - dialog dismissed, exercise still visible
        expect(find.text('Remove Exercise'), findsNothing);
        expect(find.text('Bench Press'), findsOneWidget);
      });
    });

    group('Error State', () {
      testWidgets('shows error state when loading fails', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenThrow(Exception('Network error'));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Failed to load routine'), findsOneWidget);
        expect(find.text('Error'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('retry button reloads routine', (tester) async {
        // Arrange
        var callCount = 0;
        when(() => mockRoutineRepository.getRoutine(any())).thenAnswer(
          (_) async {
            callCount++;
            if (callCount == 1) {
              throw Exception('Network error');
            }
            return createSampleRoutine();
          },
        );

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Verify error state
        expect(find.text('Failed to load routine'), findsOneWidget);

        // Tap retry
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        // Assert - should now show routine
        expect(find.text('Push Day'), findsOneWidget);
      });
    });

    group('Drag Handle', () {
      testWidgets('shows drag handles for reordering', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => createSampleRoutine());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.drag_indicator), findsNWidgets(3));
      });
    });

    group('Back Navigation', () {
      testWidgets('has app bar with title', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => createSampleRoutine(name: 'Push Day'));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert - app bar exists with routine name
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Push Day'), findsOneWidget);
      });
    });

    group('Exercise Card Layout', () {
      testWidgets('displays fitness icon', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => createSampleRoutine());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert - drag indicators visible
        expect(find.byIcon(Icons.drag_indicator), findsNWidgets(3));
      });

      testWidgets('exercise cards are in Card widgets', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.getRoutine(any()))
            .thenAnswer((_) async => createSampleRoutine());

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert - 3 exercise cards
        expect(find.byType(Card), findsNWidgets(3));
      });
    });
  });
}
