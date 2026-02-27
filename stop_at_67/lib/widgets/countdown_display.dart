import 'package:flutter/material.dart';

class CountdownDisplay extends StatelessWidget {
  final int value;

  const CountdownDisplay({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: Text(
        '$value',
        key: ValueKey(value),
        style: const TextStyle(
          fontSize: 120,
          fontWeight: FontWeight.w100,
          color: Colors.white,
        ),
      ),
    );
  }
}
