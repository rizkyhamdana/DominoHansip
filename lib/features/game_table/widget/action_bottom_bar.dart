import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:crownpass/app/theme.dart';
import 'package:crownpass/data/models/game_session_model.dart';
import 'package:crownpass/data/models/player_model.dart';

import 'package:crownpass/core/utils/domino_engine.dart';

class ActionBottomBar extends StatelessWidget {
  final GameSessionModel session;
  final String? selectedPlayerId;
  final VoidCallback? onPass;
  final VoidCallback? onSettle;
  final VoidCallback? onUndo;
  final VoidCallback? onMenu;

  const ActionBottomBar({
    super.key,
    required this.session,
    this.selectedPlayerId,
    this.onPass,
    this.onSettle,
    this.onUndo,
    this.onMenu,
  });

  bool get _canPass {
    if (selectedPlayerId == null) return false;
    
    final isDrawOrPlay = session.phase == GamePhase.initialDraw || session.phase == GamePhase.playing;
    if (!isDrawOrPlay) return false;

    // If the selected player is the one whose turn it is, check if they have valid moves (glowing tiles)
    if (session.currentTurnPlayerId == selectedPlayerId) {
      final hand = session.playerHands[selectedPlayerId!] ?? const [];
      final hasMoves = DominoEngine.hasValidMoves(hand, session.dominoChain);
      if (hasMoves) return false; // Block pass!
    }
    
    return true;
  }

  bool get _canSettle {
    final hasNoStones = session.players.any((p) => p.totalStoneCount == 0);
    final isStockEmpty = session.stockCount == 0;

    return (session.phase == GamePhase.playing ||
            session.phase == GamePhase.initialDraw ||
            session.phase == GamePhase.distributing) &&
        hasNoStones &&
        isStockEmpty;
  }

  String? get _settleTooltip {
    if (_canSettle) return null;
    return 'Game selesai jika stok di tengah habis DAN ada pemain yang batunya habis.';
  }

  bool get _canUndo => session.actionLog.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceMD,
        AppTheme.spaceSM,
        AppTheme.spaceMD,
        AppTheme.spaceMD,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.cardSurface,
        border: Border(
          top: BorderSide(color: AppTheme.cardBorder),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Pass button (primary if can pass)
            Expanded(
              flex: 2,
              child: _BarButton(
                id: 'btn_pass',
                label: 'Pass',
                icon: Icons.arrow_forward_rounded,
                color: _canPass ? AppTheme.gold : AppTheme.textMuted,
                isPrimary: _canPass,
                onTap: _canPass ? onPass : null,
                tooltip: selectedPlayerId == null
                    ? 'Pilih pemain terlebih dahulu'
                    : null,
              ),
            ),
            const SizedBox(width: AppTheme.spaceSM),

            // Settle button
            Expanded(
              flex: 2,
              child: _BarButton(
                id: 'btn_settle',
                label: 'Selesai',
                icon: Icons.flag_rounded,
                color: _canSettle ? AppTheme.success : AppTheme.textMuted,
                onTap: _canSettle ? onSettle : null,
                tooltip: _settleTooltip,
              ),
            ),
            const SizedBox(width: AppTheme.spaceSM),

            // Undo
            _IconBarButton(
              id: 'btn_undo',
              icon: Icons.undo_rounded,
              color: _canUndo ? AppTheme.textSecondary : AppTheme.textMuted,
              onTap: _canUndo ? onUndo : null,
            ),
            const SizedBox(width: AppTheme.spaceSM),

            // Menu
            _IconBarButton(
              id: 'btn_menu',
              icon: Icons.more_vert_rounded,
              color: AppTheme.textSecondary,
              onTap: onMenu,
            ),
          ],
        ),
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final bool isPrimary;
  final VoidCallback? onTap;
  final String? tooltip;

  const _BarButton({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    this.isPrimary = false,
    this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onTap != null;
    Color buttonColor = isPrimary ? AppTheme.gold : AppTheme.cardSurface;
    Color borderAccentColor = isEnabled
        ? AppTheme.cardBorder
        : AppTheme.cardBorder.withValues(alpha: 0.3);
    Color labelColor = isPrimary ? AppTheme.textPrimary : color;

    if (!isEnabled) {
      buttonColor = AppTheme.background.withValues(alpha: 0.4);
      labelColor = AppTheme.textMuted;
    }

    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          key: Key(id),
          duration: const Duration(milliseconds: 150),
          height: 48,
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(
              color: borderAccentColor,
              width: 2.0,
            ),
            boxShadow: isEnabled
                ? [
                    const BoxShadow(
                      color: AppTheme.cardBorder,
                      blurRadius: 0,
                      offset: Offset(3, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: labelColor,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: labelColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBarButton extends StatelessWidget {
  final String id;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _IconBarButton({
    required this.id,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        key: Key(id),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isEnabled
              ? AppTheme.cardSurface
              : AppTheme.background.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(
            color: isEnabled
                ? AppTheme.cardBorder
                : AppTheme.cardBorder.withValues(alpha: 0.3),
            width: 2.0,
          ),
          boxShadow: isEnabled
              ? [
                  const BoxShadow(
                    color: AppTheme.cardBorder,
                    blurRadius: 0,
                    offset: Offset(3, 3),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isEnabled ? color : AppTheme.textMuted,
        ),
      ),
    );
  }
}
