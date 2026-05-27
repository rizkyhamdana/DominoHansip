import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import 'package:crownpass/app/router.dart';
import 'package:crownpass/app/theme.dart';
import 'package:crownpass/core/constants/app_constants.dart';
import 'package:crownpass/data/models/player_model.dart';
import 'package:crownpass/features/game_table/bloc/game_table_bloc.dart';
import 'package:crownpass/features/game_table/bloc/game_table_event.dart';
import 'package:crownpass/features/vs_setup/bloc/vs_setup_bloc.dart';
import 'package:crownpass/features/vs_setup/bloc/vs_setup_event.dart';
import 'package:crownpass/features/vs_setup/bloc/vs_setup_state.dart';

const _uuid = Uuid();

// Bot avatar color — distinct slate gray
const _botAvatarColor = Color(0xFF8FA3BE);

class VsSetupPage extends StatelessWidget {
  const VsSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VsSetupBloc(),
      child: const _VsSetupView(),
    );
  }
}

class _VsSetupView extends StatelessWidget {
  const _VsSetupView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<VsSetupBloc, VsSetupState>(
      listenWhen: (prev, curr) => curr.isSubmitted && !prev.isSubmitted,
      listener: (context, setupState) {
        final humanId = _uuid.v4();
        final bot1Id = _uuid.v4();
        final bot2Id = _uuid.v4();
        final bot3Id = _uuid.v4();

        final humanPlayer = PlayerModel(
          id: humanId,
          name: setupState.playerName.trim(),
          avatarColorValue: AppTheme.avatarColors[0].toARGB32(),
        );

        final botAlpha = PlayerModel(
          id: bot1Id,
          name: '🤖 Alpha',
          avatarColorValue: const Color(0xFF8FA3BE).toARGB32(),
        );
        final botBeta = PlayerModel(
          id: bot2Id,
          name: '🤖 Beta',
          avatarColorValue: const Color(0xFF7E9E82).toARGB32(),
        );
        final botGamma = PlayerModel(
          id: bot3Id,
          name: '🤖 Gamma',
          avatarColorValue: const Color(0xFFB08E6E).toARGB32(),
        );

        context.read<GameTableBloc>().add(InitializeGame(
              players: [humanPlayer, botAlpha, botBeta, botGamma],
              totalStones: setupState.totalStones,
              isDragEnabled: false,
              isHapticEnabled: true,
              isVsMode: true,
              botPlayerIds: [bot1Id, bot2Id, bot3Id],
            ));

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.gameTable,
          (route) => route.settings.name == AppRouter.home,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Setup VS Bot'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<VsSetupBloc, VsSetupState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bot info banner
                  _BotInfoBanner(),

                  const SizedBox(height: AppTheme.spaceLG),

                  // Player name section
                  const _SectionHeader(title: 'Nama Kamu'),
                  const SizedBox(height: AppTheme.spaceSM),
                  _PlayerNameInput(
                    initialValue: state.playerName,
                    onChanged: (name) => context
                        .read<VsSetupBloc>()
                        .add(UpdateVsPlayerName(name)),
                  ),

                  const SizedBox(height: AppTheme.spaceLG),

                  // Stone config section
                  const _SectionHeader(title: 'Konfigurasi Batu'),
                  const SizedBox(height: AppTheme.spaceSM),
                  _StoneConfigCard(
                    totalStones: state.totalStones,
                    onChanged: (val) =>
                        context.read<VsSetupBloc>().add(SetVsTotalStones(val)),
                  ),

                  const SizedBox(height: AppTheme.spaceXL),

                  // Start button
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      key: const Key('btn_start_vs_game'),
                      onTap: state.isValid
                          ? () {
                              HapticFeedback.mediumImpact();
                              context
                                  .read<VsSetupBloc>()
                                  .add(const SubmitVsSetup());
                            }
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: state.isValid
                              ? AppTheme.bigStoneMaroon
                              : AppTheme.background,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLG),
                          border: Border.all(
                            color: state.isValid
                                ? AppTheme.cardBorder
                                : AppTheme.cardBorder.withValues(alpha: 0.3),
                            width: 2.5,
                          ),
                          boxShadow: state.isValid
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
                              Icons.smart_toy_rounded,
                              color: state.isValid
                                  ? Colors.white
                                  : AppTheme.textMuted,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Mulai Lawan Bot',
                              style: GoogleFonts.outfit(
                                color: state.isValid
                                    ? Colors.white
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
                        'Nama tidak boleh kosong.',
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
}

// ── Bot Info Banner ──────────────────────────────────────────────────────────

class _BotInfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.bigStoneMaroon.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: AppTheme.bigStoneMaroon.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _botAvatarColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              border: Border.all(
                color: AppTheme.cardBorder.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: AppTheme.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🤖 Bot',
                  style: GoogleFonts.outfit(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Bot akan otomatis pass, pilih causer, dan bagi batu sesuai aturan.',
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Player Name Input ────────────────────────────────────────────────────────

class _PlayerNameInput extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const _PlayerNameInput({
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_PlayerNameInput> createState() => _PlayerNameInputState();
}

class _PlayerNameInputState extends State<_PlayerNameInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMD,
        vertical: AppTheme.spaceSM,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppTheme.cardBorder, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardBorder,
            blurRadius: 0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.avatarColors.first,
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              border: Border.all(color: AppTheme.cardBorder, width: 2),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppTheme.textPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppTheme.spaceMD),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              style: GoogleFonts.outfit(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Nama kamu...',
                hintStyle: GoogleFonts.outfit(
                  color: AppTheme.textMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stone Config Card ────────────────────────────────────────────────────────

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
                    key: const Key('btn_vs_stones_decrease'),
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
                    key: const Key('btn_vs_stones_increase'),
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
              const _StoneInfo(
                label: 'Batu Besar',
                value: '1 💎',
                color: AppTheme.bigStoneMaroon,
              ),
              _StoneInfo(
                label: 'Batu Kecil',
                value: '${totalStones - 1} ⚪',
                color: AppTheme.textPrimary,
              ),
              const _StoneInfo(
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
