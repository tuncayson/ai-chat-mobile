import 'package:ai_chat_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadii.messageBubble),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    return Padding(
                      padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
                      child: _Dot(
                        opacity: _opacityFor(i),
                        color: theme.colorScheme.onSurface,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  double _opacityFor(int dotIndex) {
    // Phase each dot by 1/3 of the cycle. Within each phase, opacity rises
    // linearly from 0.3 → 1.0 then falls back to 0.3.
    final phase = (_controller.value - dotIndex / 3 + 1) % 1;
    final triangle = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
    return 0.3 + 0.7 * triangle;
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.opacity, required this.color});

  final double opacity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
