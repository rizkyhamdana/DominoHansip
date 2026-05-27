import 'package:flutter/material.dart';

import 'package:crownpass/app/theme.dart';

class CrownBadge extends StatefulWidget {
  final double size;
  final bool animated;

  const CrownBadge({super.key, this.size = 20, this.animated = false});

  @override
  State<CrownBadge> createState() => _CrownBadgeState();
}

class _CrownBadgeState extends State<CrownBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.bounceOut)));
    if (widget.animated) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.scale(
          scale: widget.animated ? _scale.value : 1.0,
          child: Container(
            width: widget.size + 8,
            height: widget.size + 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.gold,
              border: Border.all(color: AppTheme.cardBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.cardBorder.withOpacity(0.15),
                  blurRadius: 0,
                  offset: const Offset(1.5, 1.5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '👴',
                style: TextStyle(
                  fontSize: widget.size * 0.9,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
