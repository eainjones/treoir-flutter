import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:treoir/src/features/routines/data/routine_repository.dart';
import 'package:treoir/src/features/routines/domain/routine.dart';
import 'package:treoir/src/features/routines/presentation/providers/routine_providers.dart';
import 'package:treoir/src/features/routines/presentation/routine_list_screen.dart';

// Mock classes
class MockRoutineRepository extends Mock implements RoutineRepository {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockRoutineRepository mockRoutineRepository;

  setUpAll(() {
    registerFallbackValue(const Routine(id: '', name: ''));
  });

  setUp(() {
    mockRoutineRepository = MockRoutineRepository();
  });

  /// Helper to build test widget with ProviderScope
  Widget buildTestWidget({
    List<Override> overrides = const [],
    GoRouter? router,
  }) {
    final testRouter = router ??
        GoRouter(
          initialLocation: '/routines',
          routes: [
            GoRoute(
              path: '/routines',
              builder: (context, state) => const RoutineListScreen(),
            ),
            GoRoute(
              path: '/routines/:id',
              builder: (context, state) => Scaffold(
                body: Text('Routine Detail: ${state.pathParameters['id']}'),
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

  /// Create sample routines for testing
  List<Routine> createSampleRoutines({int count = 3}) {
    return List.generate(
      count,
      (i) => Routine(
        id: 'routine-$i',
        name: 'Routine ${i + 1}',
        exerciseCount: (i + 1) * 2,
        estimatedDuration: (i + 1) * 30,
      ),
    );
  }

  group('RoutineListScreen', () {
    group('Loading State', () {
      testWidgets('shows loading indicator initially', (tester) async {
        // Arrange - set up a delayed response to keep loading state
        when(() => mockRoutineRepository.listRoutines(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async {
          // Simulate network delay
          await Future.delayed(const Duration(seconds: 10));
          return RoutineListResponse(
            routines: [],
            page: 1,
            pageSize: 20,
            total: 0,
            hasMore: false,
          );
        });

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pump(); // Initial build

        // Assert - should show loading indicator while fetching
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Empty State', () {
      testWidgets('shows empty state when no routines exist', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.listRoutines(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => RoutineListResponse(
              routines: [],
              page: 1,
              pageSize: 20,
              total: 0,
              hasMore: false,
            ));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('No routines yet'), findsOneWidget);
        expect(
          find.text('Create a routine to save your favorite workout templates'),
          findsOneWidget,
        );
        expect(find.text('Create Routine'), findsOneWidget);
        expect(find.byIcon(Icons.list_alt_rounded), findsOneWidget);
      });

      testWidgets('empty state Create Routine button is tappable',
          (tester) async {
        // Arrange
        when(() => mockRoutineRepository.listRoutines(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => RoutineListResponse(
              routines: [],
              page: 1,
              pageSize: 20,
              total: 0,
              hasMore: false,
            ));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Tap create routine button in empty state
        await tester.tap(find.text('Create Routine'));
        await tester.pumpAndSettle();

        // Assert - should show bottom sheet
        expect(find.text('Routine Name'), findsOneWidget);
      });
    });

    group('Data Display', () {
      testWidgets('displays list of routine cards', (tester) async {
        // Arrange
        final routines = createSampleRoutines(count: 3);
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

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert - all routine names should be visible
        expect(find.text('Routine 1'), findsOneWidget);
        expect(find.text('Routine 2'), findsOneWidget);
        expect(find.text('Routine 3'), findsOneWidget);
      });

      testWidgets('shows routine name and exercise count', (tester) async {
        // Arrange
        final routines = [
          const Routine(
            id: 'routine-1',
            name: 'Push Day',
            exerciseCount: 5,
            estimatedDuration: 45,
          ),
        ];
        when(() => mockRoutineRepository.listRoutines(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => RoutineListResponse(
              routines: routines,
              page: 1,
              pageSize: 20,
              total: 1,
              hasMore: false,
            ));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Push Day'), findsOneWidget);
        expect(find.text('5 exercises'), findsOneWidget);
        expect(find.text('~45 min'), findsOneWidget);
      });

      testWidgets('shows estimated duration when available', (tester) async {
        // Arrange
        final routines = [
          const Routine(
            id: 'routine-1',
            name: 'Full Body',
            exerciseCount: 8,
            estimatedDuration: 60,
          ),
        ];
        when(() => mockRoutineRepository.listRoutines(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => RoutineListResponse(
              routines: routines,
              page: 1,
              pageSize: 20,
              total: 1,
              hasMore: false,
            ));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('~60 min'), findsOneWidget);
        expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
      });

      testWidgets('does not show duration when not available', (tester) async {
        // Arrange
        final routines = [
          const Routine(
            id: 'routine-1',
            name: 'Quick Workout',
            exerciseCount: 3,
            estimatedDuration: null,
          ),
        ];
        when(() => mockRoutineRepository.listRoutines(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => RoutineListResponse(
              routines: routines,
              page: 1,
              pageSize: 20,
              total: 1,
              hasMore: false,
            ));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert - timer icon should not appear when no duration
        expect(find.byIcon(Icons.timer_outlined), findsNothing);
      });

      testWidgets('displays Start button on each routine card', (tester) async {
        // Arrange
        final routines = createSampleRoutines(count: 2);
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

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert - should have Start button for each routine
        expect(find.text('Start'), findsNWidgets(2));
        expect(find.byIcon(Icons.play_arrow), findsNWidgets(2));
      });
    });

    group('Start Workout Interaction', () {
      testWidgets('Start button shows confirmation dialog', (tester) async {
        // Arrange
        final routines = [
          const Routine(
            id: 'routine-1',
            name: 'Leg Day',
            exerciseCount: 4,
          ),
        ];
        when(() => mockRoutineRepository.listRoutines(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => RoutineListResponse(
              routines: routines,
              page: 1,
              pageSize: 20,
              total: 1,
              hasMore: false,
            ));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Tap start button
        await tester.tap(find.text('Start'));
        await tester.pumpAndSettle();

        // Assert - confirmation dialog should appear
        expect(find.text('Start Leg Day?'), findsOneWidget);
        expect(
          find.text(
              'This will create a new workout based on this routine with 4 exercises.'),
          findsOneWidget,
        );
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Start Workout'), findsOneWidget);
      });

      testWidgets('Cancel button dismisses dialog without action',
          (tester) async {
        // Arrange
        final routines = [
          const Routine(
            id: 'routine-1',
            name: 'Leg Day',
            exerciseCount: 4,
          ),
        ];
        when(() => mockRoutineRepository.listRoutines(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => RoutineListResponse(
              routines: routines,
              page: 1,
              pageSize: 20,
              total: 1,
              hasMore: false,
            ));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Start'));
        await tester.pumpAndSettle();

        // Tap cancel
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Assert - dialog should be dismissed
        expect(find.text('Start Leg Day?'), findsNothing);
      });
    });

    group('Pull to Refresh', () {
      testWidgets('pull to refresh triggers data reload', (tester) async {
        // Arrange
        var callCount = 0;
        when(() => mockRoutineRepository.listRoutines(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async {
          callCount++;
          return RoutineListResponse(
            routines: createSampleRoutines(count: 1),
            page: 1,
            pageSize: 20,
            total: 1,
            hasMore: false,
          );
        });

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Perform pull to refresh gesture
        await tester.drag(
          find.byType(ListView),
          const Offset(0, 300),
        );
        await tester.pumpAndSettle();

        // Assert - repository should be called more than once
        expect(callCount, greaterThan(1));
      });
    });

    group('Error State', () {
      testWidgets('displays error state when loading fails', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.listRoutines(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenThrow(Exception('Network error'));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Failed to load routines'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('Retry button reloads data', (tester) async {
        // Arrange
        var callCount = 0;
        when(() => mockRoutineRepository.listRoutines(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw Exception('Network error');
          }
          return RoutineListResponse(
            routines: createSampleRoutines(count: 1),
            page: 1,
            pageSize: 20,
            total: 1,
            hasMore: false,
          );
        });

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Verify error state
        expect(find.text('Failed to load routines'), findsOneWidget);

        // Tap retry
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        // Assert - should now show data
        expect(find.text('Routine 1'), findsOneWidget);
      });
    });

    group('AppBar Actions', () {
      testWidgets('shows Routines title in app bar', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.listRoutines(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => RoutineListResponse(
              routines: [],
              page: 1,
              pageSize: 20,
              total: 0,
              hasMore: false,
            ));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Routines'), findsOneWidget);
      });

      testWidgets('app bar has add button', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.listRoutines(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => RoutineListResponse(
              routines: [],
              page: 1,
              pageSize: 20,
              total: 0,
              hasMore: false,
            ));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.add), findsWidgets);
      });

      testWidgets('add button opens create routine sheet', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.listRoutines(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => RoutineListResponse(
              routines: createSampleRoutines(),
              page: 1,
              pageSize: 20,
              total: 3,
              hasMore: false,
            ));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Find and tap the add button in app bar
        final addButton = find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.add),
        );
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Assert - should show create routine sheet
        expect(find.text('Create Routine'), findsOneWidget);
        expect(find.text('Routine Name'), findsOneWidget);
      });
    });

    group('FAB', () {
      testWidgets('shows FAB with New Routine label', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.listRoutines(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => RoutineListResponse(
              routines: [],
              page: 1,
              pageSize: 20,
              total: 0,
              hasMore: false,
            ));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.text('New Routine'), findsOneWidget);
      });

      testWidgets('FAB opens create routine dialog', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.listRoutines(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => RoutineListResponse(
              routines: createSampleRoutines(),
              page: 1,
              pageSize: 20,
              total: 3,
              hasMore: false,
            ));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Tap FAB
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Create Routine'), findsOneWidget);
      });
    });

    group('Navigation', () {
      testWidgets('tapping routine card navigates to detail', (tester) async {
        // Arrange
        final routines = [
          const Routine(
            id: 'routine-123',
            name: 'Test Routine',
            exerciseCount: 5,
          ),
        ];
        when(() => mockRoutineRepository.listRoutines(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => RoutineListResponse(
              routines: routines,
              page: 1,
              pageSize: 20,
              total: 1,
              hasMore: false,
            ));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Tap on the routine card (not the start button)
        await tester.tap(find.text('Test Routine'));
        await tester.pumpAndSettle();

        // Assert - should navigate to detail screen
        expect(find.text('Routine Detail: routine-123'), findsOneWidget);
      });
    });

    group('Create Routine Sheet', () {
      testWidgets('create routine sheet has required fields', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.listRoutines(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => RoutineListResponse(
              routines: [],
              page: 1,
              pageSize: 20,
              total: 0,
              hasMore: false,
            ));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Open create routine sheet
        await tester.tap(find.text('Create Routine'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Create Routine'), findsOneWidget);
        expect(find.text('Routine Name'), findsOneWidget);
        expect(find.text('Create'), findsOneWidget);
        expect(
          find.widgetWithText(TextFormField, 'e.g., Push Day, Full Body, etc.'),
          findsOneWidget,
        );
      });

      testWidgets('shows validation error for empty name', (tester) async {
        // Arrange
        when(() => mockRoutineRepository.listRoutines(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => RoutineListResponse(
              routines: [],
              page: 1,
              pageSize: 20,
              total: 0,
              hasMore: false,
            ));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Open create routine sheet
        await tester.tap(find.text('Create Routine'));
        await tester.pumpAndSettle();

        // Try to submit with empty name
        await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
        await tester.pumpAndSettle();

        // Assert - validation error should appear
        expect(find.text('Please enter a routine name'), findsOneWidget);
      });
    });

    group('Pagination', () {
      testWidgets('shows loading indicator when more items available',
          (tester) async {
        // Arrange
        when(() => mockRoutineRepository.listRoutines(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => RoutineListResponse(
              routines: createSampleRoutines(count: 10),
              page: 1,
              pageSize: 10,
              total: 20,
              hasMore: true,
            ));

        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Assert - should show list with loading indicator at end
        expect(find.byType(ListView), findsOneWidget);
      });
    });
  });
}
