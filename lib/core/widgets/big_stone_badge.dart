import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:crownpass/app/theme.dart';

class BigStoneBadge extends StatelessWidget {
  final double size;

  const BigStoneBadge({super.key, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 12,
      height: size + 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.bigStoneMaroon,
        border: Border.all(color: AppTheme.cardBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cardBorder.withValues(alpha: 0.18),
            blurRadius: 0,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '5',
          style: GoogleFonts.outfit(
            color: AppTheme.gold,
            fontSize: size * 0.75,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
