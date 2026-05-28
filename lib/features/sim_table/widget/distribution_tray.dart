import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:crownpass/app/theme.dart';
import 'package:crownpass/core/utils/game_rule_utils.dart';
import 'package:crownpass/data/models/player_model.dart';
import 'package:crownpass/features/sim_table/bloc/sim_table_bloc.dart';
import 'package:crownpass/features/sim_table/bloc/sim_table_event.dart';
import 'package:crownpass/features/sim_table/widget/stone_chip.dart';

class DistributionTray extends StatefulWidget {
  final PlayerModel distributor;
  final List<PlayerModel> targets;
  final bool isDragEnabled;
  final Function(String toPlayerId, StoneType stoneType) onDistribute;

  const DistributionTray({
    super.key,
    required this.distributor,
    required this.targets,
    required this.isDragEnabled,
    required this.onDistribute,
  });

  @override
  State<DistributionTray> createState() => _DistributionTrayState();
}

class _DistributionTrayState extends State<DistributionTray> {
  StoneType? _selectedStone;

  @override
  void initState() {
    super.initState();
    // Automatically select the stone if distributor has only 1 type of stone
    final distributor = widget.distributor;
    if (distributor.smallStoneCount > 0 && !distributor.hasBigStone) {
      _selectedStone = StoneType.small;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context
              .read<SimTableBloc>()
              .add(const SelectStoneForDistribution(StoneType.small));
        }
      });
    } else if (distributor.hasBigStone && distributor.smallStoneCount == 0) {
      _selectedStone = StoneType.big;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context
              .read<SimTableBloc>()
              .add(const SelectStoneForDistribution(StoneType.big));
        }
      });
    }
  }

  void _selectStone(StoneType type, bool isLocked) {
    if (isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Batu Besar hanya bisa dibagi terakhir.',
            style: GoogleFonts.inter(color: AppTheme.textPrimary),
          ),
          backgroundColor: AppTheme.cardSurface,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _selectedStone = type);
    context.read<SimTableBloc>().add(SelectStoneForDistribution(type));
  }

  @override
  Widget build(BuildContext context) {
    final distributor = widget.distributor;
    final canBig = GameRuleUtils.canDistributeBigStone(distributor);
    final bigLocked = !canBig && distributor.hasBigStone;

    return Container(
      width: 140,
      height: 175,
      padding: const EdgeInsets.all(AppTheme.spaceSM),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: AppTheme.cardBorder,
          width: 2.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardBorder,
            blurRadius: 0,
            offset: Offset(3.5, 3.5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'BAGI BATU',
            style: GoogleFonts.outfit(
              color: AppTheme.warning,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            distributor.name,
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),
          const Divider(height: 1, color: AppTheme.cardBorder),
          const SizedBox(height: AppTheme.spaceSM),

          // Distributor stones
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Small stones
                  ...List.generate(
                    distributor.smallStoneCount,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: StoneChip(
                        type: StoneType.small,
                        isLocked: false,
                        isDraggable: widget.isDragEnabled,
                        fromPlayerId: distributor.id,
                        onTap: () => _selectStone(StoneType.small, false),
                        isSelected: _selectedStone == StoneType.small,
                      ),
                    ),
                  ),

                  // Big stone (if has it)
                  if (distributor.hasBigStone)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: StoneChip(
                        type: StoneType.big,
                        isLocked: bigLocked,
                        isDraggable: widget.isDragEnabled && !bigLocked,
                        fromPlayerId: distributor.id,
                        onTap: () => _selectStone(StoneType.big, bigLocked),
                        isSelected: _selectedStone == StoneType.big,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),
          Text(
            'Pilih batu lalu pemain',
            style: GoogleFonts.inter(
              color: AppTheme.textMuted,
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
