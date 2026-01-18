import 'dart:async';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/settings/presentation/settings_screen.dart';

part 'rest_timer_provider.g.dart';

/// Rest timer state
class RestTimerState {
  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;
  final bool isFinished;

  const RestTimerState({
    required this.totalSeconds,
    required this.remainingSeconds,
    this.isRunning = false,
    this.isFinished = false,
  });

  RestTimerState copyWith({
    int? totalSeconds,
    int? remainingSeconds,
    bool? isRunning,
    bool? isFinished,
  }) {
    return RestTimerState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      isFinished: isFinished ?? this.isFinished,
    );
  }

  /// Progress from 0.0 to 1.0
  double get progress {
    if (totalSeconds == 0) return 0;
    return (totalSeconds - remainingSeconds) / totalSeconds;
  }

  /// Formatted time display
  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Whether timer is idle (not started or already finished and reset)
  bool get isIdle => !isRunning && remainingSeconds == totalSeconds;
}

/// Rest timer notifier
@riverpod
class RestTimer extends _$RestTimer {
  Timer? _timer;

  @override
  RestTimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });

    final defaultDuration = ref.watch(defaultRestTimerProvider);
    return RestTimerState(
      totalSeconds: defaultDuration,
      remainingSeconds: defaultDuration,
    );
  }

  /// Start the timer
  void start({int? durationSeconds}) {
    _timer?.cancel();

    final int duration = durationSeconds ?? ref.read(defaultRestTimerProvider);

    state = RestTimerState(
      totalSeconds: duration,
      remainingSeconds: duration,
      isRunning: true,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(
          remainingSeconds: state.remainingSeconds - 1,
        );
      } else {
        _onTimerComplete();
      }
    });
  }

  /// Pause the timer
  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  /// Resume the timer
  void resume() {
    if (state.remainingSeconds <= 0 || state.isRunning) return;

    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(
          remainingSeconds: state.remainingSeconds - 1,
        );
      } else {
        _onTimerComplete();
      }
    });
  }

  /// Reset the timer
  void reset() {
    _timer?.cancel();
    final defaultDuration = ref.read(defaultRestTimerProvider);
    state = RestTimerState(
      totalSeconds: defaultDuration,
      remainingSeconds: defaultDuration,
    );
  }

  /// Add time to the timer
  void addTime(int seconds) {
    state = state.copyWith(
      totalSeconds: state.totalSeconds + seconds,
      remainingSeconds: state.remainingSeconds + seconds,
    );
  }

  /// Skip the remaining time
  void skip() {
    _timer?.cancel();
    state = state.copyWith(
      remainingSeconds: 0,
      isRunning: false,
      isFinished: true,
    );
  }

  void _onTimerComplete() {
    _timer?.cancel();
    state = state.copyWith(
      isRunning: false,
      isFinished: true,
    );

    // Haptic feedback
    final vibrationEnabled = ref.read(timerVibrationEnabledProvider);
    if (vibrationEnabled) {
      HapticFeedback.heavyImpact();
    }

    // TODO: Play sound if enabled
    // final soundEnabled = ref.read(timerSoundEnabledProvider);
    // if (soundEnabled) {
    //   AudioPlayer().play('assets/sounds/timer_complete.mp3');
    // }
  }
}
