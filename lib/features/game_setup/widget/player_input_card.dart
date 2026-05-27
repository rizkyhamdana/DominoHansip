import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:crownpass/app/theme.dart';
import 'package:crownpass/core/widgets/player_avatar.dart';
import 'package:crownpass/features/game_setup/widget/avatar_color_picker.dart';

class PlayerInputCard extends StatefulWidget {
  final int index;
  final String name;
  final int colorValue;
  final Set<int> unavailableColorValues;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<int> onColorChanged;

  const PlayerInputCard({
    super.key,
    required this.index,
    required this.name,
    required this.colorValue,
    this.unavailableColorValues = const {},
    required this.onNameChanged,
    required this.onColorChanged,
  });

  @override
  State<PlayerInputCard> createState() => _PlayerInputCardState();
}

class _PlayerInputCardState extends State<PlayerInputCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.name);
  }

  @override
  void didUpdateWidget(PlayerInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.name != widget.name && _controller.text != widget.name) {
      _controller.text = widget.name;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: AppDecorations.glassCard(
        color: AppTheme.cardSurface,
        radius: AppTheme.radiusMD,
      ),
      child: Row(
        children: [
          // Avatar preview
          PlayerAvatar(
            name: widget.name,
            colorValue: widget.colorValue,
            radius: 20,
          ),
          const SizedBox(width: AppTheme.spaceMD),
          // Name input
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _controller,
                  onChanged: widget.onNameChanged,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Nama Pemain ${widget.index + 1}',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      borderSide: const BorderSide(
                          color: AppTheme.cardBorder, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      borderSide: const BorderSide(
                          color: AppTheme.cardBorder, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      borderSide: const BorderSide(
                          color: AppTheme.goldDark, width: 2.5),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceSM),
                AvatarColorPicker(
                  selectedColorValue: widget.colorValue,
                  disabledColorValues: widget.unavailableColorValues,
                  onColorSelected: widget.onColorChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
