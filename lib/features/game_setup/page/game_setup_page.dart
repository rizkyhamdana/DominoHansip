import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:crownpass/app/router.dart';
import 'package:crownpass/app/theme.dart';
import 'package:crownpass/core/constants/app_constants.dart';
import 'package:crownpass/features/game_setup/bloc/game_setup_bloc.dart';
import 'package:crownpass/features/game_setup/bloc/game_setup_event.dart';
import 'package:crownpass/features/game_setup/bloc/game_setup_state.dart';
import 'package:crownpass/features/game_setup/widget/player_input_card.dart';
import 'package:crownpass/features/game_table/bloc/game_table_bloc.dart';
import 'package:crownpass/features/game_table/bloc/game_table_event.dart';

class GameSetupPage extends StatelessWidget {
  const GameSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameSetupBloc(),
      child: const _GameSetupView(),
    );
  }
}

class _GameSetupView extends StatelessWidget {
  const _GameSetupView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameSetupBloc, GameSetupState>(
      listenWhen: (prev, curr) => curr.isSubmitted && !prev.isSubmitted,
      listener: (context, setupState) {
        final setupBloc = context.read<GameSetupBloc>();
        final players = setupBloc.buildPlayerModels();
        context.read<GameTableBloc>().add(InitializeGame(
              players: players,
              totalStones: setupState.totalStones,
              isDragEnabled: setupState.isDragEnabled,
              isHapticEnabled: setupState.isHapticEnabled,
            ));
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.gameTable,
          (route) => route.settings.name == AppRouter.home,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pengaturan Permainan'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<GameSetupBloc, GameSetupState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Player count section
                  _SectionHeader(title: 'Jumlah Pemain'),
                  const SizedBox(height: AppTheme.spaceSM),
                  _PlayerCountSelector(
                    selectedCount: state.playerCount,
                    onChanged: (count) => context
                        .read<GameSetupBloc>()
                        .add(SetPlayerCount(count)),
                  ),

                  const SizedBox(height: AppTheme.spaceLG),
                  _SectionHeader(title: 'Nama Pemain'),
                  const SizedBox(height: AppTheme.spaceSM),

                  // Player input cards
                  ...List.generate(state.players.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spaceSM),
                      child: PlayerInputCard(
                        index: i,
                        name: state.players[i].name,
                        colorValue: state.players[i].colorValue,
                        unavailableColorValues: state.players
                            .asMap()
                            .entries
                            .where((entry) => entry.key != i)
                            .map((entry) => entry.value.colorValue)
                            .toSet(),
                        onNameChanged: (name) => context
                            .read<GameSetupBloc>()
                            .add(UpdatePlayerName(i, name)),
                        onColorChanged: (color) => context
                            .read<GameSetupBloc>()
                            .add(UpdatePlayerColor(i, color)),
                      ),
                    );
                  }),

                  const SizedBox(height: AppTheme.spaceLG),
                  _SectionHeader(title: 'Konfigurasi Batu'),
                  const SizedBox(height: AppTheme.spaceSM),

                  // Stone config
                  _StoneConfigCard(
                    totalStones: state.totalStones,
                    onChanged: (val) =>
                        context.read<GameSetupBloc>().add(SetTotalStones(val)),
                  ),

                  const SizedBox(height: AppTheme.spaceLG),
                  // _SectionHeader(title: 'Pengaturan Interaksi'),
                  // const SizedBox(height: AppTheme.spaceSM),

                  // // Toggles
                  // _ToggleCard(
                  //   label: 'Geser Batu (Drag & Drop)',
                  //   subtitle: 'Geser batu ke pemain tujuan saat distribusi',
                  //   value: state.isDragEnabled,
                  //   onChanged: (_) => context
                  //       .read<GameSetupBloc>()
                  //       .add(const ToggleDragEnabled()),
                  // ),
                  // const SizedBox(height: AppTheme.spaceSM),
                  // _ToggleCard(
                  //   label: 'Haptic Feedback',
                  //   subtitle: 'Getaran saat pass dan distribusi batu',
                  //   value: state.isHapticEnabled,
                  //   onChanged: (_) => context
                  //       .read<GameSetupBloc>()
                  //       .add(const ToggleHapticEnabled()),
                  // ),

                  // const SizedBox(height: AppTheme.spaceXL),

                  // Start button
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      key: const Key('btn_start_round'),
                      onTap: state.isValid
                          ? () {
                              HapticFeedback.mediumImpact();
                              context
                                  .read<GameSetupBloc>()
                                  .add(const SubmitSetup());
                            }
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: state.isValid
                              ? AppTheme.gold
                              : AppTheme.background,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLG),
                          border: Border.all(
                            color: state.isValid
                                ? AppTheme.cardBorder
                                : AppTheme.cardBorder.withOpacity(0.3),
                            width: 2.5,
                          ),
                          boxShadow: state.isValid
                              ? [
                                  const BoxShadow(
                                    color: AppTheme.cardBorder,
                                    blurRadius: 0,
                                    offset: Offset(3, 3),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_arrow_rounded,
                              color: state.isValid
                                  ? AppTheme.textPrimary
                                  : AppTheme.textMuted,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Mulai Game Baru',
                              style: GoogleFonts.outfit(
                                color: state.isValid
                                    ? AppTheme.textPrimary
                                    : AppTheme.textMuted,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  if (!state.isValid)
                    Padding(
                      padding: const EdgeInsets.only(top: AppTheme.spaceSM),
                      child: Text(
                        _validationMessage(state),
                        style: GoogleFonts.inter(
                          color: AppTheme.error,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: AppTheme.spaceXXL),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _validationMessage(GameSetupState state) {
    final emptyName = state.players.any((p) => p.name.trim().isEmpty);
    if (emptyName) return 'Nama pemain tidak boleh kosong.';
    final names =
        state.players.map((p) => p.name.trim().toLowerCase()).toList();
    if (names.length != names.toSet().length) {
      return 'Nama pemain harus berbeda.';
    }
    if (state.totalStones < state.playerCount + 1) {
      return 'Total batu minimal ${state.playerCount + 1} untuk ${state.playerCount} pemain.';
    }
    return 'Periksa pengaturan kembali.';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.outfit(
          color: AppTheme.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _PlayerCountSelector extends StatelessWidget {
  final int selectedCount;
  final ValueChanged<int> onChanged;

  const _PlayerCountSelector({
    required this.selectedCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        AppConstants.maxPlayers - AppConstants.minPlayers + 1,
        (i) {
          final count = AppConstants.minPlayers + i;
          final isSelected = count == selectedCount;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onChanged(count);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(right: 8),
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.gold : AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  border: Border.all(
                    color: AppTheme.cardBorder,
                    width: 2.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          const BoxShadow(
                            color: AppTheme.cardBorder,
                            blurRadius: 0,
                            offset: Offset(2, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: GoogleFonts.outfit(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StoneConfigCard extends StatelessWidget {
  final int totalStones;
  final ValueChanged<int> onChanged;

  const _StoneConfigCard({
    required this.totalStones,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: AppDecorations.glassCard(
        color: AppTheme.cardSurface,
        radius: AppTheme.radiusMD,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Batu Game',
                      style: GoogleFonts.outfit(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Batu pertama selalu Batu Besar (5 poin)',
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    key: const Key('btn_stones_decrease'),
                    onPressed: totalStones > AppConstants.minTotalStones
                        ? () {
                            HapticFeedback.lightImpact();
                            onChanged(totalStones - 1);
                          }
                        : null,
                    icon: const Icon(Icons.remove_circle_rounded),
                    color: AppTheme.textPrimary,
                    iconSize: 28,
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 32),
                    alignment: Alignment.center,
                    child: Text(
                      '$totalStones',
                      style: GoogleFonts.outfit(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('btn_stones_increase'),
                    onPressed: totalStones < 50
                        ? () {
                            HapticFeedback.lightImpact();
                            onChanged(totalStones + 1);
                          }
                        : null,
                    icon: const Icon(Icons.add_circle_rounded),
                    color: AppTheme.textPrimary,
                    iconSize: 28,
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24, thickness: 2, color: AppTheme.cardBorder),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StoneInfo(
                label: 'Batu Besar',
                value: '1 💎',
                color: AppTheme.bigStoneMaroon,
              ),
              _StoneInfo(
                label: 'Batu Kecil',
                value: '${totalStones - 1} ⚪',
                color: AppTheme.textPrimary,
              ),
              _StoneInfo(
                label: 'Nilai Besar',
                value: '5 Poin',
                color: AppTheme.goldDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoneInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StoneInfo({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ToggleCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleCard({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMD,
        vertical: AppTheme.spaceSM,
      ),
      decoration: AppDecorations.glassCard(
        color: AppTheme.cardSurface,
        radius: AppTheme.radiusMD,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (val) {
              HapticFeedback.lightImpact();
              onChanged(val);
            },
            activeColor: AppTheme.gold,
            activeTrackColor: AppTheme.gold.withOpacity(0.3),
            inactiveThumbColor: AppTheme.textSecondary,
            inactiveTrackColor: AppTheme.background,
            trackOutlineColor: WidgetStateProperty.all(AppTheme.cardBorder),
          ),
        ],
      ),
    );
  }
}
