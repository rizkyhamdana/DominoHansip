import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:crownpass/app/theme.dart';

class PlayerAvatar extends StatelessWidget {
  final String name;
  final int colorValue;
  final double radius;
  final bool isHighlighted;

  static const List<String> avatarEmojis = [
    '🦊', // Fox
    '🐼', // Panda
    '🐸', // Frog
    '🐯', // Tiger
    '🐨', // Koala
    '🦁', // Lion
    '🦉', // Owl
    '🐙', // Octopus
    '🦖', // T-Rex
    '🦄', // Unicorn
  ];

  const PlayerAvatar({
    super.key,
    required this.name,
    required this.colorValue,
    this.radius = 24,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);
    final colorIndex =
        AppTheme.avatarColors.indexWhere((color) => color.value == colorValue);
    final emojiIndex = colorIndex >= 0
        ? colorIndex % avatarEmojis.length
        : colorValue.abs() % avatarEmojis.length;
    final emoji = avatarEmojis[emojiIndex];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.35),
        border: Border.all(
          color: AppTheme.cardBorder,
          width: isHighlighted ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isHighlighted
                ? color.withOpacity(0.4)
                : AppTheme.cardBorder.withOpacity(0.12),
            blurRadius: 0,
            offset: isHighlighted ? const Offset(3, 3) : const Offset(1.5, 1.5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: GoogleFonts.outfit(
            fontSize: radius * 1.1,
          ),
        ),
      ),
    );
  }
}
