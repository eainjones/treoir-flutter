import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/workout/presentation/workout_home_screen.dart';
import '../../features/workout/presentation/active_workout_screen.dart';
import '../../features/workout/presentation/workout_summary_screen.dart';
import '../../features/history/presentation/workout_history_screen.dart';
import '../../features/history/presentation/workout_detail_screen.dart';
import '../../features/exercises/presentation/exercise_picker_screen.dart';
import '../../features/routines/presentation/routine_list_screen.dart';
import '../../features/routines/presentation/routine_detail_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/workout/domain/workout.dart';

/// Route names
class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  static const String activeWorkout = '/workout/:id';
  static const String workoutSummary = '/workout/:id/summary';
  static const String history = '/history';
  static const String workoutDetail = '/history/:id';
  static const String exercisePicker = '/exercises/pick';
  static const String routines = '/routines';
  static const String routineDetail = '/routines/:id';
  static const String settings = '/settings';
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == AppRoutes.login;

      if (!isAuthenticated) {
        return isLoggingIn ? null : AppRoutes.login;
      }

      if (isLoggingIn) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Main routes
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const WorkoutHomeScreen(),
      ),

      // Active workout
      GoRoute(
        path: AppRoutes.activeWorkout,
        name: 'activeWorkout',
        builder: (context, state) {
          final workoutId = state.pathParameters['id']!;
          return ActiveWorkoutScreen(workoutId: workoutId);
        },
        routes: [
          // Workout summary (nested under active workout)
          GoRoute(
            path: 'summary',
            name: 'workoutSummary',
            builder: (context, state) {
              final workout = state.extra as Workout?;
              if (workout == null) {
                // Redirect to home if no workout data
                return const WorkoutHomeScreen();
              }
              return WorkoutSummaryScreen(workout: workout);
            },
          ),
        ],
      ),

      // History
      GoRoute(
        path: AppRoutes.history,
        name: 'history',
        builder: (context, state) => const WorkoutHistoryScreen(),
      ),

      // Workout detail
      GoRoute(
        path: AppRoutes.workoutDetail,
        name: 'workoutDetail',
        builder: (context, state) {
          final workoutId = state.pathParameters['id']!;
          return WorkoutDetailScreen(workoutId: workoutId);
        },
      ),

      // Exercise picker (returns selected exercise via pop)
      GoRoute(
        path: AppRoutes.exercisePicker,
        name: 'exercisePicker',
        pageBuilder: (context, state) => MaterialPage<dynamic>(
          key: state.pageKey,
          child: const ExercisePickerScreen(),
        ),
      ),

      // Routines
      GoRoute(
        path: AppRoutes.routines,
        name: 'routines',
        builder: (context, state) => const RoutineListScreen(),
      ),

      // Routine detail
      GoRoute(
        path: AppRoutes.routineDetail,
        name: 'routineDetail',
        builder: (context, state) {
          final routineId = state.pathParameters['id']!;
          return RoutineDetailScreen(routineId: routineId);
        },
      ),

      // Settings
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
});
