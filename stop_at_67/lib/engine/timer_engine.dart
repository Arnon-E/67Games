import 'dart:async';
import 'dart:math';
import 'types.dart';

class PrecisionTimer {
  final void Function(TimerState) onTick;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  bool _countdown = false;
  int _countdownFrom = 0;
  double _speedMultiplier = 1.0;
  int _virtualElapsed = 0;

  PrecisionTimer({required this.onTick});

  void setCountdown(bool enabled, int fromMs) {
    _countdown = enabled;
    _countdownFrom = fromMs;
  }

  void setSpeedMultiplier(double multiplier) {
    _speedMultiplier = multiplier.clamp(1.0, 10.0);
  }

  void start() {
    if (_stopwatch.isRunning) return;
    _virtualElapsed = 0;
    _stopwatch.reset();
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(milliseconds: 16), _tick);
  }

  void _tick(Timer t) {
    _virtualElapsed += (16 * _speedMultiplier).round();
    final displayMs = _countdown ? max(0, _countdownFrom - _virtualElapsed) : _virtualElapsed;

    onTick(TimerState(
      isRunning: true,
      elapsedMs: _stopwatch.elapsedMilliseconds,
      displayTime: _formatTime(displayMs),
      speedMultiplier: _speedMultiplier,
    ));

    if (_countdown && displayMs <= 0) {
      stop();
    }
  }

  /// Stops the timer and returns real elapsed ms.
  int stop() {
    _ticker?.cancel();
    _ticker = null;
    _stopwatch.stop();

    final elapsed = _stopwatch.elapsedMilliseconds;
    final displayMs = _countdown ? max(0, _countdownFrom - _virtualElapsed) : _virtualElapsed;

    onTick(TimerState(
      isRunning: false,
      elapsedMs: elapsed,
      displayTime: _formatTime(displayMs),
      speedMultiplier: _speedMultiplier,
    ));

    return elapsed;
  }

  /// Returns the virtual (displayed) elapsed value — used for scoring in speed modes.
  int getStoppedValue(int elapsedMs) {
    if (_countdown) return max(0, _countdownFrom - _virtualElapsed);
    return _virtualElapsed;
  }

  void reset() {
    stop();
    _virtualElapsed = 0;
    _stopwatch.reset();
    onTick(TimerState(
      isRunning: false,
      elapsedMs: 0,
      displayTime: _formatTime(_countdown ? _countdownFrom : 0),
      speedMultiplier: _speedMultiplier,
    ));
  }

  bool get isRunning => _stopwatch.isRunning;

  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
  }

  String _formatTime(int ms) {
    final totalMs = ms.clamp(0, 9999999);
    final seconds = totalMs ~/ 1000;
    final millis = totalMs % 1000;
    return '$seconds.${millis.toString().padLeft(3, '0')}';
  }
}
