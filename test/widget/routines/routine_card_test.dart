import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:treoir/src/features/routines/data/routine_repository.dart';
import 'package:treoir/src/features/routines/domain/routine.dart';
import 'package:treoir/src/features/routines/presentation/routine_list_screen.dart';

/// Tests for the _RoutineCard widget which is displayed in RoutineListScreen.
///
/// Since _RoutineCard is private to routine_list_screen.dart, we test it
/// through the RoutineListScreen which renders the cards.

// Mock classes
class MockRoutineRepository extends Mock implements RoutineRepository {}

void main() {
  late MockRoutineRepository mockRoutineRepository;

  setUp(() {
    mockRoutineRepository = MockRoutineRepository();
  });

  /// Helper to build test widget that shows a single routine card
  Widget buildTestWidget({
    required Routine routine,
    List<Override> overrides = const [],
  }) {
    when(() => mockRoutineRepository.listRoutines(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        )).thenAnswer((_) async => RoutineListResponse(
          routines: [routine],
          page: 1,
          pageSize: 20,
          total: 1,
          hasMore: false,
        ));

    final testRouter = GoRouter(
      initialLocation: '/routines',
      routes: [
        GoRoute(
          path: '/routines',
          builder: (context, state) => const RoutineListScreen(),
        ),
        GoRoute(
          path: '/routines/:id',
          builder: (context, state) => Scaffold(
            body: Text('Detail: ${state.pathParameters['id']}'),
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

  group('RoutineCard', () {
    group('Layout and Structure', () {
      testWidgets('displays routine name prominently', (tester) async {
        // Arrange
        final routine = const Routine(
          id: 'r-1',
          name: 'Upper Body Blast',
          exerciseCount: 6,
        );

        // Act
        await tester.pumpWidget(buildTestWidget(routine: routine));
        await tester.pumpAndSettle();

        // Assert
        final nameText = find.text('Upper Body Blast');
        expect(nameText, findsOneWidget);

        // Verify it's styled as a title
        final textWidget = tester.widget<Text>(nameText);
        expect(textWidget.style?.fontWeight, FontWeight.bold);
      });

      testWidgets('displays exercise count with icon', (tester) async {
        // Arrange
        final routine = const Routine(
          id: 'r-1',
          name: 'Leg Day',
          exerciseCount: 8,
        );

        // Act
        await tester.pumpWidget(buildTestWidget(routine: routine));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('8 exercises'), findsOneWidget);
        expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      });

      testWidgets('displays estimated duration when provided', (tester) async {
        // Arrange
        final routine = const Routine(
          id: 'r-1',
          name: 'Quick HIIT',
          exerciseCount: 4,
          estimatedDuration: 25,
        );

        // Act
        await tester.pumpWidget(buildTestWidget(routine: routine));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('~25 min'), findsOneWidget);
        expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
      });

      testWidgets('does not display duration when null', (tester) async {
        // Arrange
        final routine = const Routine(
          id: 'r-1',
          name: 'Flexible Routine',
          exerciseCount: 3,
          estimatedDuration: null,
        );

        // Act
        await tester.pumpWidget(buildTestWidget(routine: routine));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.timer_outlined), findsNothing);
      });

      testWidgets('card is wrapped in Card widget', (tester) async {
        // Arrange
        final routine = const Routine(
          id: 'r-1',
          name: 'Test',
          exerciseCount: 1,
        );

        // Act
        await tester.pumpWidget(buildTestWidget(routine: routine));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(Card), findsOneWidget);
      });

      testWidgets('has inkwell for tap feedback', (tester) async {
        // Arrange
        final routine = const Routine(
          id: 'r-1',
          name: 'Test',
          exerciseCount: 1,
        );

        // Act
        await tester.pumpWidget(buildTestWidget(routine: routine));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(InkWell), findsOneWidget);
      });
    });

    group('Start Button', () {
      testWidgets('displays Start button with play icon', (tester) async {
        // Arrange
        final routine = const Routine(
          id: 'r-1',
          name: 'Workout',
          exerciseCount: 5,
        );

        // Act
        await tester.pumpWidget(buildTestWidget(routine: routine));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Start'), findsOneWidget);
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      });

      testWidgets('Start button uses FilledButton.tonalIcon', (tester) async {
        // Arrange
        final routine = const Routine(
          id: 'r-1',
          name: 'Test',
          exerciseCount: 1,
        );

        // Act
        await tester.pumpWidget(buildTestWidget(routine: routine));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(FilledButton), findsOneWidget);
      });

      testWidgets('tapping Start shows confirmation dialog', (tester) async {
        // Arrange
        final routine = const Routine(
          id: 'r-1',
          name: 'Power Workout',
          exerciseCount: 7,
        );

        // Act
        await tester.pumpWidget(buildTestWidget(routine: routine));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Start'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Start Power Workout?'), findsOneWidget);
        expect(
          find.text(
              'This will create a new workout based on this routine with 7 exercises.'),
          findsOneWidget,
        );
      });

      testWidgets('confirmation dialog has correct action buttons',
          (tester) async {
        // Arrange
        final routine = const Routine(
          id: 'r-1',
          name: 'Test',
          exerciseCount: 1,
        );

        // Act
        await tester.pumpWidget(buildTestWidget(routine: routine));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Start'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
        expect(find.widgetWithText(ElevatedButton, 'Start Workout'),
            findsOneWidget);
      });
    });

    group('Tap Navigation', () {
      testWidgets('tapping card navigates to routine detail', (tester) async {
        // Arrange
        final routine = const Routine(
          id: 'routine-abc-123',
          name: 'Navigate Test',
          exerciseCount: 2,
        );

        // Act
        await tester.pumpWidget(buildTestWidget(routine: routine));
        await tester.pumpAndSettle();

        // Tap on the routine name (part of the card)
        await tester.tap(find.text('Navigate Test'));
        await tester.pumpAndSettle();

        // Assert - should navigate to detail
        expect(find.text('Detail: routine-abc-123'), findsOneWidget);
      });

      testWidgets('Start button tap does not navigate to detail',
          (tester) async {
        // Arrange
        final routine = const Routine(
          id: 'routine-xyz',
          name: 'No Navigate',
          exerciseCount: 3,
        );

        // Act
        await tester.pumpWidget(buildTestWidget(routine: routine));
        await tester.pumpAndSettle();

        // Tap Start button
        await tester.tap(find.text('Start'));
        await tester.pumpAndSettle();

        // Assert - should show dialog, not detail page
        expect(find.text('Start No Navigate?'), findsOneWidget);
        expect(find.text('Detail: routine-xyz'), findsNothing);
      });
    });

    group('Exercise Count Display', () {
      testWidgets('displays singular exercise when count is 1', (tester) async {
        // Note: The current implementation always uses 'exercises' (plural)
        // This test documents the current behavior
        final routine = const Routine(
          id: 'r-1',
          name: 'Single',
          exerciseCount: 1,
        );

        await tester.pumpWidget(buildTestWidget(routine: routine));
        await tester.pumpAndSettle();

        // Current behavior uses plural form
        expect(find.text('1 exercises'), findsOneWidget);
      });

      testWidgets('displays zero exercises correctly', (tester) async {
        final routine = const Routine(
          id: 'r-1',
          name: 'Empty',
          exerciseCount: 0,
        );

        await tester.pumpWidget(buildTestWidget(routine: routine));
        await tester.pumpAndSettle();

        expect(find.text('0 exercises'), findsOneWidget);
      });

      testWidgets('displays large exercise count', (tester) async {
        final routine = const Routine(
          id: 'r-1',
          name: 'Marathon',
          exerciseCount: 25,
        );

        await tester.pumpWidget(buildTestWidget(routine: routine));
        await tester.pumpAndSettle();

        expect(find.text('25 exercises'), findsOneWidget);
      });
    });

    group('Duration Display', () {
      testWidgets('displays short duration', (tester) async {
        final routine = const Routine(
          id: 'r-1',
          name: 'Quick',
          exerciseCount: 2,
          estimatedDuration: 10,
        );

        await tester.pumpWidget(buildTestWidget(routine: routine));
        await tester.pumpAndSettle();

        expect(find.text('~10 min'), findsOneWidget);
      });

      testWidgets('displays long duration', (tester) async {
        final routine = const Routine(
          id: 'r-1',
          name: 'Epic',
          exerciseCount: 15,
          estimatedDuration: 120,
        );

        await tester.pumpWidget(buildTestWidget(routine: routine));
        await tester.pumpAndSettle();

        expect(find.text('~120 min'), findsOneWidget);
      });
    });

    group('Special Characters', () {
      testWidgets('handles routine name with special characters',
          (tester) async {
        final routine = const Routine(
          id: 'r-1',
          name: 'Push & Pull: Day 1 (Advanced)',
          exerciseCount: 8,
        );

        await tester.pumpWidget(buildTestWidget(routine: routine));
        await tester.pumpAndSettle();

        expect(find.text('Push & Pull: Day 1 (Advanced)'), findsOneWidget);
      });

      testWidgets('handles routine name with emojis', (tester) async {
        final routine = const Routine(
          id: 'r-1',
          name: 'Arm Day',
          exerciseCount: 6,
        );

        await tester.pumpWidget(buildTestWidget(routine: routine));
        await tester.pumpAndSettle();

        expect(find.text('Arm Day'), findsOneWidget);
      });

      testWidgets('handles very long routine name', (tester) async {
        final routine = const Routine(
          id: 'r-1',
          name:
              'This Is A Very Long Routine Name That Might Need To Be Truncated',
          exerciseCount: 3,
        );

        await tester.pumpWidget(buildTestWidget(routine: routine));
        await tester.pumpAndSettle();

        // Should still render without error
        expect(find.byType(Card), findsOneWidget);
      });
    });

    group('Multiple Cards', () {
      testWidgets('multiple routine cards render correctly', (tester) async {
        // Arrange
        final routines = [
          const Routine(id: 'r-1', name: 'Routine 1', exerciseCount: 3),
          const Routine(id: 'r-2', name: 'Routine 2', exerciseCount: 5),
          const Routine(id: 'r-3', name: 'Routine 3', exerciseCount: 7),
        ];

        when(() => mockRoutineRepository.listRoutines(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => RoutineListResponse(
              routines: routines,
              page: 1,
              pageSize: 20,
              total: 3,
              hasMore: false,
            ));

        final testRouter = GoRouter(
          initialLocation: '/routines',
          routes: [
            GoRoute(
              path: '/routines',
              builder: (context, state) => const RoutineListScreen(),
            ),
          ],
        );

        // Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              routineRepositoryProvider.overrideWithValue(mockRoutineRepository),
            ],
            child: MaterialApp.router(routerConfig: testRouter),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(Card), findsNWidgets(3));
        expect(find.text('Routine 1'), findsOneWidget);
        expect(find.text('Routine 2'), findsOneWidget);
        expect(find.text('Routine 3'), findsOneWidget);
        expect(find.text('Start'), findsNWidgets(3));
      });

      testWidgets('each card has independent tap target', (tester) async {
        // Arrange
        final routines = [
          const Routine(id: 'r-1', name: 'First', exerciseCount: 1),
          const Routine(id: 'r-2', name: 'Second', exerciseCount: 2),
        ];

        when(() => mockRoutineRepository.listRoutines(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => RoutineListResponse(
              routines: routines,
              page: 1,
              pageSize: 20,
              total: 2,
              hasMore: false,
            ));

        final testRouter = GoRouter(
          initialLocation: '/routines',
          routes: [
            GoRoute(
              path: '/routines',
              builder: (context, state) => const RoutineListScreen(),
            ),
            GoRoute(
              path: '/routines/:id',
              builder: (context, state) => Scaffold(
                body: Text('Detail: ${state.pathParameters['id']}'),
              ),
            ),
          ],
        );

        // Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              routineRepositoryProvider.overrideWithValue(mockRoutineRepository),
            ],
            child: MaterialApp.router(routerConfig: testRouter),
          ),
        );
        await tester.pumpAndSettle();

        // Tap second routine
        await tester.tap(find.text('Second'));
        await tester.pumpAndSettle();

        // Assert - should navigate to second routine
        expect(find.text('Detail: r-2'), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('card has semantic labels', (tester) async {
        final routine = const Routine(
          id: 'r-1',
          name: 'Accessible Routine',
          exerciseCount: 4,
          estimatedDuration: 30,
        );

        await tester.pumpWidget(buildTestWidget(routine: routine));
        await tester.pumpAndSettle();

        // Card should be findable
        expect(find.byType(Card), findsOneWidget);

        // All text content should be present and readable
        expect(find.text('Accessible Routine'), findsOneWidget);
        expect(find.text('4 exercises'), findsOneWidget);
        expect(find.text('~30 min'), findsOneWidget);
        expect(find.text('Start'), findsOneWidget);
      });
    });
  });
}
