import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:crownpass/app/router.dart';
import 'package:crownpass/app/theme.dart';
import 'package:crownpass/core/constants/app_constants.dart';
import 'package:crownpass/data/models/player_model.dart';
import 'package:crownpass/features/game_table/bloc/game_table_bloc.dart';
import 'package:crownpass/features/game_table/bloc/game_table_event.dart';
import 'package:crownpass/features/game_table/bloc/game_table_state.dart';
import 'package:crownpass/features/home/widget/session_info_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GameTableBloc, GameTableState>(
        builder: (context, state) {
          final session = state.session;
          final hasGame = session.hasActiveGame;

          return Container(
            color: AppTheme.background,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceLG,
                  vertical: AppTheme.spaceMD,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppTheme.spaceXL),

                    // Logo & Title
                    _buildHeader(),

                    const SizedBox(height: AppTheme.spaceXL),

                    // Session info (shown if game exists)
                    if (hasGame) ...[
                      SessionInfoCard(
                        crownPlayer: session.crownPlayer,
                        hansipPlayer: session.hansipPlayer,
                        totalRounds: session.roundHistory.length,
                      ),
                      const SizedBox(height: AppTheme.spaceLG),
                    ],

                    // Main menu buttons
                    _MainMenuButton(
                      id: 'btn_start_game',
                      label: 'Mulai Permainan Baru',
                      icon: Icons.play_arrow_rounded,
                      isPrimary: true,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRouter.modeSelect),
                    ),

                    if (hasGame) ...[
                      _MainMenuButton(
                        id: 'btn_continue_game',
                        label: 'Lanjutkan Game',
                        icon: Icons.sports_esports_rounded,
                        isPrimary: false,
                        onTap: () => _continueGame(context, state),
                      ),
                    ],

                    _MainMenuButton(
                      id: 'btn_history',
                      label: 'Riwayat Game',
                      icon: Icons.history_rounded,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRouter.history),
                    ),

                    _MainMenuButton(
                      id: 'btn_statistics',
                      label: 'Statistik Pemain',
                      icon: Icons.leaderboard_rounded,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRouter.statistics),
                    ),

                    if (hasGame) ...[
                      const SizedBox(height: AppTheme.spaceSM),
                      TextButton.icon(
                        onPressed: () => _confirmReset(context),
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppTheme.error),
                        label: Text(
                          'Hapus Game Aktif',
                          style: GoogleFonts.outfit(
                            color: AppTheme.error,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppTheme.spaceXL),

                    // Bottom tagline sticker
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 16, vertical: 8),
                    //   decoration: BoxDecoration(
                    //     color: AppTheme.cardSurface,
                    //     borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    //     border:
                    //         Border.all(color: AppTheme.cardBorder, width: 2),
                    //   ),
                    //   child: Text(
                    //     AppConstants.appTagline,
                    //     style: GoogleFonts.inter(
                    //       color: AppTheme.textSecondary,
                    //       fontSize: 12,
                    //       fontWeight: FontWeight.w700,
                    //     ),
                    //     textAlign: TextAlign.center,
                    //   ),
                    // ),
                    const SizedBox(height: AppTheme.spaceMD),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.cardSurface,
            border: Border.all(color: AppTheme.cardBorder, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppTheme.cardBorder.withValues(alpha: 0.15),
                blurRadius: 0,
                offset: const Offset(3, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: ClipOval(
            child: Image.asset(
              'assets/images/app_logo.png',
              fit: BoxFit.cover,
              semanticLabel: AppConstants.appName,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spaceMD),
        Text(
          AppConstants.appName,
          style: GoogleFonts.outfit(
            color: AppTheme.textPrimary,
            fontSize: 38,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: AppTheme.spaceXS),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.teal.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusRound),
            border: Border.all(color: AppTheme.cardBorder, width: 1.5),
          ),
          child: Text(
            AppConstants.appSubtitle.toUpperCase(),
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          side: const BorderSide(color: AppTheme.cardBorder, width: 2),
        ),
        title: Text(
          'Reset Game?',
          style: GoogleFonts.outfit(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Semua data game saat ini akan dihapus permanen. Data riwayat game sebelumnya dan statistik global tetap tersimpan dengan aman.',
          style: GoogleFonts.inter(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.outfit(
                  color: AppTheme.textSecondary, fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              context.read<GameTableBloc>().add(const ResetGame());
              Navigator.pop(ctx);
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  void _continueGame(BuildContext context, GameTableState state) {
    if (state.session.phase == GamePhase.roundFinished) {
      context.read<GameTableBloc>().add(const StartNextRound());
    }

    Navigator.pushNamed(context, AppRouter.gameTable);
  }
}

class _MainMenuButton extends StatelessWidget {
  final String id;
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _MainMenuButton({
    required this.id,
    required this.label,
    required this.icon,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const shadowColor = AppTheme.cardBorder;
    final buttonColor = isPrimary ? AppTheme.gold : AppTheme.cardSurface;
    const textColor = AppTheme.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        key: Key(id),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            border: Border.all(color: AppTheme.cardBorder, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: shadowColor,
                blurRadius: 0,
                offset: Offset(3, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: textColor,
                  fontSize: 16,
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
