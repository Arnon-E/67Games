import 'dart:async';
import 'dart:math';
import 'types.dart';

class PrecisionTimer {
  final void Function(TimerState) onTick;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  bool _countdown = false;
  int _countdownFrom = 0;

  PrecisionTimer({required this.onTick});

  void setCountdown(bool enabled, int fromMs) {
    _countdown = enabled;
    _countdownFrom = fromMs;
  }

  void start() {
    if (_stopwatch.isRunning) return;
    _stopwatch.reset();
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(milliseconds: 16), _tick);
  }

  void _tick(Timer t) {
    final elapsed = _stopwatch.elapsedMilliseconds;
    final displayMs = _countdown ? max(0, _countdownFrom - elapsed) : elapsed;

    onTick(TimerState(
      isRunning: true,
      elapsedMs: elapsed,
      displayTime: _formatTime(displayMs),
    ));

    if (_countdown && displayMs <= 0) {
      stop();
    }
  }

  /// Stops the timer and returns elapsed ms.
  int stop() {
    _ticker?.cancel();
    _ticker = null;
    _stopwatch.stop();

    final elapsed = _stopwatch.elapsedMilliseconds;
    final displayMs = _countdown ? max(0, _countdownFrom - elapsed) : elapsed;

    onTick(TimerState(
      isRunning: false,
      elapsedMs: elapsed,
      displayTime: _formatTime(displayMs),
    ));

    return elapsed;
  }

  /// For countdown mode: returns the countdown value at stop time.
  int getStoppedValue(int elapsedMs) {
    if (_countdown) return max(0, _countdownFrom - elapsedMs);
    return elapsedMs;
  }

  void reset() {
    stop();
    _stopwatch.reset();
    onTick(TimerState(
      isRunning: false,
      elapsedMs: 0,
      displayTime: _formatTime(_countdown ? _countdownFrom : 0),
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
