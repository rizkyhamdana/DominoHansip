import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:crownpass/app/theme.dart';
import 'package:crownpass/core/constants/app_constants.dart';
import 'package:crownpass/core/widgets/crown_badge.dart';
import 'package:crownpass/core/widgets/hansip_badge.dart';
import 'package:crownpass/data/models/player_model.dart';

class SessionInfoCard extends StatelessWidget {
  final PlayerModel? crownPlayer;
  final PlayerModel? hansipPlayer;
  final int totalRounds;

  const SessionInfoCard({
    super.key,
    this.crownPlayer,
    this.hansipPlayer,
    this.totalRounds = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: AppDecorations.glassCard(
        color: AppTheme.cardSurface,
        radius: AppTheme.radiusLG,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sesi Terakhir',
            style: GoogleFonts.outfit(
              color: AppTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppTheme.spaceMD),
          Row(
            children: [
              _InfoTile(
                icon: const CrownBadge(size: 16),
                label: 'Kepala Desa',
                value: crownPlayer?.name ?? AppConstants.noCrownHolder,
                color: AppTheme.gold,
              ),
              const SizedBox(width: AppTheme.spaceMD),
              _InfoTile(
                icon: const HansipBadge(size: 16),
                label: 'Hansip',
                value: hansipPlayer?.name ?? AppConstants.noHansip,
                color: AppTheme.teal,
              ),
              const SizedBox(width: AppTheme.spaceMD),
              _InfoTile(
                icon: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.textMuted.withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.loop_rounded,
                    color: AppTheme.textMuted,
                    size: 14,
                  ),
                ),
                label: 'Game',
                value: '$totalRounds',
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
