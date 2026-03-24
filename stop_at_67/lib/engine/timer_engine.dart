import 'dart:async';
import 'dart:math';
import 'types.dart';

class PrecisionTimer {
  final void Function(TimerState) onTick;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  bool _countdown = false;
  // Stored internally in tenths-of-ms (0.1 ms units) for 4-decimal display.
  int _countdownFrom = 0;
  double _speedMultiplier = 1.0;
  // _virtualElapsed is in tenths-of-ms. Each 16 ms tick = 160 tenths.
  int _virtualElapsed = 0;

  PrecisionTimer({required this.onTick});

  void setCountdown(bool enabled, int fromMs) {
    _countdown = enabled;
    _countdownFrom = fromMs * 10; // convert ms → tenths-of-ms
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
    // Each 16 ms tick = 160 tenths-of-ms at 1× speed.
    _virtualElapsed += (160 * _speedMultiplier).round();
    final displayTenths = _countdown
        ? max(0, _countdownFrom - _virtualElapsed)
        : _virtualElapsed;

    onTick(TimerState(
      isRunning: true,
      elapsedMs: _stopwatch.elapsedMilliseconds,
      displayTime: _formatTime(displayTenths),
      speedMultiplier: _speedMultiplier,
    ));

    if (_countdown && displayTenths <= 0) {
      stop();
    }
  }

  /// Stops the timer and returns real elapsed ms.
  int stop() {
    _ticker?.cancel();
    _ticker = null;
    _stopwatch.stop();

    final elapsed = _stopwatch.elapsedMilliseconds;
    final displayTenths = _countdown
        ? max(0, _countdownFrom - _virtualElapsed)
        : _virtualElapsed;

    onTick(TimerState(
      isRunning: false,
      elapsedMs: elapsed,
      displayTime: _formatTime(displayTenths),
      speedMultiplier: _speedMultiplier,
    ));

    return elapsed;
  }

  /// Returns the virtual (displayed) elapsed value in whole ms —
  /// used for scoring. Converts internal tenths-of-ms back to ms.
  int getStoppedValue(int elapsedMs) {
    if (_countdown) return max(0, _countdownFrom - _virtualElapsed) ~/ 10;
    return _virtualElapsed ~/ 10;
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

  /// Formats tenths-of-ms into a 4-decimal display string.
  /// e.g. 67040 tenths → "6.7040", 670000 tenths → "67.0000"
  String _formatTime(int tenths) {
    final totalTenths = tenths.clamp(0, 9999999);
    final seconds = totalTenths ~/ 10000;
    final sub = totalTenths % 10000;
    return '$seconds.${sub.toString().padLeft(4, '0')}';
  }
}
