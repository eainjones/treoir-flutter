import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treoir/src/shared/providers/rest_timer_provider.dart';
import 'package:treoir/src/features/settings/presentation/settings_screen.dart';

void main() {
  group('RestTimerState', () {
    test('initial state has correct defaults', () {
      const state = RestTimerState(
        totalSeconds: 90,
        remainingSeconds: 90,
      );

      expect(state.isRunning, false);
      expect(state.isFinished, false);
      expect(state.isIdle, true);
    });

    group('progress', () {
      test('returns 0 when not started', () {
        const state = RestTimerState(
          totalSeconds: 90,
          remainingSeconds: 90,
        );
        expect(state.progress, 0.0);
      });

      test('returns correct progress mid-timer', () {
        const state = RestTimerState(
          totalSeconds: 100,
          remainingSeconds: 50,
          isRunning: true,
        );
        expect(state.progress, 0.5);
      });

      test('returns 1 when finished', () {
        const state = RestTimerState(
          totalSeconds: 90,
          remainingSeconds: 0,
          isFinished: true,
        );
        expect(state.progress, 1.0);
      });

      test('handles zero total seconds', () {
        const state = RestTimerState(
          totalSeconds: 0,
          remainingSeconds: 0,
        );
        expect(state.progress, 0.0);
      });
    });

    group('formattedTime', () {
      test('formats seconds only', () {
        const state = RestTimerState(
          totalSeconds: 45,
          remainingSeconds: 45,
        );
        expect(state.formattedTime, '0:45');
      });

      test('formats minutes and seconds', () {
        const state = RestTimerState(
          totalSeconds: 90,
          remainingSeconds: 90,
        );
        expect(state.formattedTime, '1:30');
      });

      test('pads seconds with zero', () {
        const state = RestTimerState(
          totalSeconds: 65,
          remainingSeconds: 65,
        );
        expect(state.formattedTime, '1:05');
      });

      test('formats zero correctly', () {
        const state = RestTimerState(
          totalSeconds: 90,
          remainingSeconds: 0,
        );
        expect(state.formattedTime, '0:00');
      });
    });

    group('isIdle', () {
      test('true when not running and remaining equals total', () {
        const state = RestTimerState(
          totalSeconds: 90,
          remainingSeconds: 90,
          isRunning: false,
        );
        expect(state.isIdle, true);
      });

      test('false when running', () {
        const state = RestTimerState(
          totalSeconds: 90,
          remainingSeconds: 90,
          isRunning: true,
        );
        expect(state.isIdle, false);
      });

      test('false when remaining differs from total', () {
        const state = RestTimerState(
          totalSeconds: 90,
          remainingSeconds: 45,
          isRunning: false,
        );
        expect(state.isIdle, false);
      });
    });

    group('copyWith', () {
      test('updates specified fields', () {
        const original = RestTimerState(
          totalSeconds: 90,
          remainingSeconds: 90,
        );

        final updated = original.copyWith(
          remainingSeconds: 45,
          isRunning: true,
        );

        expect(updated.totalSeconds, 90);
        expect(updated.remainingSeconds, 45);
        expect(updated.isRunning, true);
        expect(updated.isFinished, false);
      });
    });
  });

  group('RestTimer Notifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          // Override default rest timer to 90 seconds
          defaultRestTimerProvider.overrideWith((ref) => 90),
          timerVibrationEnabledProvider.overrideWith((ref) => false),
          timerSoundEnabledProvider.overrideWith((ref) => false),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state uses default duration', () {
      final state = container.read(restTimerProvider);

      expect(state.totalSeconds, 90);
      expect(state.remainingSeconds, 90);
      expect(state.isRunning, false);
      expect(state.isIdle, true);
    });

    test('start sets timer to running', () {
      container.read(restTimerProvider.notifier).start();

      final state = container.read(restTimerProvider);

      expect(state.isRunning, true);
      expect(state.totalSeconds, 90);
      expect(state.remainingSeconds, 90);
    });

    test('start with custom duration', () {
      container.read(restTimerProvider.notifier).start(durationSeconds: 120);

      final state = container.read(restTimerProvider);

      expect(state.totalSeconds, 120);
      expect(state.remainingSeconds, 120);
      expect(state.isRunning, true);
    });

    test('pause stops the timer', () {
      container.read(restTimerProvider.notifier).start();
      container.read(restTimerProvider.notifier).pause();

      final state = container.read(restTimerProvider);

      expect(state.isRunning, false);
    });

    test('reset restores to default duration', () {
      container.read(restTimerProvider.notifier).start(durationSeconds: 120);
      container.read(restTimerProvider.notifier).reset();

      final state = container.read(restTimerProvider);

      expect(state.totalSeconds, 90); // back to default
      expect(state.remainingSeconds, 90);
      expect(state.isRunning, false);
      expect(state.isIdle, true);
    });

    test('addTime increases remaining and total', () {
      container.read(restTimerProvider.notifier).start();
      container.read(restTimerProvider.notifier).addTime(30);

      final state = container.read(restTimerProvider);

      expect(state.totalSeconds, 120);
      expect(state.remainingSeconds, 120);
    });

    test('skip sets remaining to 0 and marks finished', () {
      container.read(restTimerProvider.notifier).start();
      container.read(restTimerProvider.notifier).skip();

      final state = container.read(restTimerProvider);

      expect(state.remainingSeconds, 0);
      expect(state.isRunning, false);
      expect(state.isFinished, true);
    });

    test('resume does nothing if already running', () {
      container.read(restTimerProvider.notifier).start();
      final stateBefore = container.read(restTimerProvider);

      container.read(restTimerProvider.notifier).resume();
      final stateAfter = container.read(restTimerProvider);

      expect(stateAfter.isRunning, stateBefore.isRunning);
    });

    test('resume does nothing if remaining is 0', () {
      container.read(restTimerProvider.notifier).skip();

      container.read(restTimerProvider.notifier).resume();
      final state = container.read(restTimerProvider);

      expect(state.isRunning, false);
    });
  });
}
