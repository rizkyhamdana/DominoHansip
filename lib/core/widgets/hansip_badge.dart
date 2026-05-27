import 'package:flutter/material.dart';

import 'package:crownpass/app/theme.dart';

class HansipBadge extends StatelessWidget {
  final double size;

  const HansipBadge({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 8,
      height: size + 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.teal,
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
          '👮',
          style: TextStyle(
            fontSize: size * 0.9,
          ),
        ),
      ),
    );
  }
}
