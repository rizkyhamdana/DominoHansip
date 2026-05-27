import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:crownpass/app/theme.dart';
import 'package:crownpass/core/widgets/crown_badge.dart';
import 'package:crownpass/core/widgets/hansip_badge.dart';
import 'package:crownpass/data/models/game_session_model.dart';
import 'package:crownpass/data/models/player_model.dart';

class GameCenterPanel extends StatelessWidget {
  final GameSessionModel session;

  const GameCenterPanel({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: AppTheme.cardBorder,
          width: 2.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardBorder,
            blurRadius: 0,
            offset: Offset(2.5, 2.5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Game Number & Indicator
          Row(
            children: [
              Text(
                'GAME ${session.currentRoundNumber}',
                style: GoogleFonts.outfit(
                  color: AppTheme.goldDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              // Mini phase dot
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _phaseColor(session.phase),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(height: 1, color: AppTheme.cardBorder),
          const SizedBox(height: 6),

          // Stock Info
          _CenterRow(
            icon: Icons.inventory_2_rounded,
            label: 'Stok:',
            value: session.stockCount > 0 ? '${session.stockCount} batu' : 'Habis',
            color: session.stockCount > 0 ? AppTheme.textPrimary : AppTheme.textMuted,
          ),
          const SizedBox(height: 6),

          // Kepala Desa
          _CenterRow(
            iconWidget: const CrownBadge(size: 11),
            label: 'Kades:',
            value: session.crownPlayer?.name ?? 'Belum ada',
            color: session.crownPlayer != null ? AppTheme.textPrimary : AppTheme.textMuted,
          ),
          const SizedBox(height: 6),

          // Hansip
          _CenterRow(
            iconWidget: const HansipBadge(size: 11),
            label: 'Hansip:',
            value: session.hansipPlayer?.name ?? 'Belum ada',
            color: session.hansipPlayer != null ? AppTheme.teal : AppTheme.textMuted,
          ),
        ],
      ),
    );
  }

  Color _phaseColor(GamePhase phase) {
    switch (phase) {
      case GamePhase.initialDraw:
        return AppTheme.textSecondary;
      case GamePhase.playing:
        return AppTheme.success;
      case GamePhase.distributing:
        return AppTheme.warning;
      case GamePhase.roundSettlement:
      case GamePhase.roundFinished:
        return AppTheme.gold;
      case GamePhase.setup:
        return AppTheme.textMuted;
    }
  }
}

class _CenterRow extends StatelessWidget {
  final Widget? iconWidget;
  final IconData? icon;
  final String label;
  final String value;
  final Color color;

  const _CenterRow({
    this.iconWidget,
    this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        iconWidget ?? Icon(icon, size: 11, color: AppTheme.textMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppTheme.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
