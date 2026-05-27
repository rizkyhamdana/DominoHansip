import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:crownpass/app/theme.dart';

class AvatarColorPicker extends StatelessWidget {
  final int selectedColorValue;
  final Set<int> disabledColorValues;
  final ValueChanged<int> onColorSelected;

  const AvatarColorPicker({
    super.key,
    required this.selectedColorValue,
    this.disabledColorValues = const {},
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: AppTheme.avatarColors.map((color) {
        final colorValue = color.toARGB32();
        final isSelected = colorValue == selectedColorValue;
        final isDisabled =
            disabledColorValues.contains(colorValue) && !isSelected;
        return GestureDetector(
          onTap: isDisabled
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onColorSelected(colorValue);
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(right: 8),
            width: isSelected ? 28 : 24,
            height: isSelected ? 28 : 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDisabled ? color.withValues(alpha: 0.25) : color,
              border: Border.all(
                color: isDisabled ? AppTheme.textMuted : AppTheme.cardBorder,
                width: 2.0,
              ),
              boxShadow: isSelected
                  ? [
                      const BoxShadow(
                        color: AppTheme.cardBorder,
                        blurRadius: 0,
                        offset: Offset(1.5, 1.5),
                      )
                    ]
                  : null,
            ),
            child: isDisabled
                ? const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: AppTheme.textMuted,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
