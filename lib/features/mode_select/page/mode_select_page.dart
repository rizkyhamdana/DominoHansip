import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:crownpass/app/router.dart';
import 'package:crownpass/app/theme.dart';

class ModeSelectPage extends StatefulWidget {
  const ModeSelectPage({super.key});

  @override
  State<ModeSelectPage> createState() => _ModeSelectPageState();
}

class _ModeSelectPageState extends State<ModeSelectPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Mode'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: AppTheme.background,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceLG,
                  vertical: AppTheme.spaceMD,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppTheme.spaceLG),

                    Text(
                      'Mode Permainan',
                      style: GoogleFonts.outfit(
                        color: AppTheme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceXS),
                    Text(
                      'Pilih cara bermain yang kamu inginkan',
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: AppTheme.spaceXL),

                    // VS Mode Card
                    _ModeCard(
                      id: 'btn_mode_vs',
                      title: 'VS Bot',
                      subtitle:
                          'Tantang kecerdasan buatan.\nKamu vs Bot — siapa yang menang?',
                      icon: Icons.smart_toy_rounded,
                      badgeLabel: '1 Pemain',
                      accentColor: AppTheme.bigStoneMaroon,
                      isPrimary: true,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRouter.vsSetup),
                    ),

                    const SizedBox(height: AppTheme.spaceMD),

                    // Simulasi Mode Card
                    _ModeCard(
                      id: 'btn_mode_sim',
                      title: 'Simulasi',
                      subtitle:
                          'Simulasikan jalannya permainan secara manual.\n3 sampai 6 pemain secara bergantian.',
                      icon: Icons.settings_suggest_rounded,
                      badgeLabel: '3–6 Pemain',
                      accentColor: AppTheme.teal,
                      isPrimary: false,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRouter.gameSetup),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatefulWidget {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String badgeLabel;
  final Color accentColor;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ModeCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badgeLabel,
    required this.accentColor,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isPrimary ? AppTheme.gold : AppTheme.cardSurface;

    return GestureDetector(
      key: Key(widget.id),
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        transform: Matrix4.translationValues(
          _pressed ? 2 : 0,
          _pressed ? 2 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          border: Border.all(color: AppTheme.cardBorder, width: 2.5),
          boxShadow: _pressed
              ? []
              : [
                  const BoxShadow(
                    color: AppTheme.cardBorder,
                    blurRadius: 0,
                    offset: Offset(4, 4),
                  ),
                ],
        ),
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: widget.accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                border: Border.all(
                  color: widget.accentColor.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: Icon(
                widget.icon,
                color: widget.accentColor,
                size: 32,
              ),
            ),
            const SizedBox(width: AppTheme.spaceMD),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.outfit(
                          color: AppTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spaceSM),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: widget.accentColor.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusRound),
                          border: Border.all(
                            color: widget.accentColor.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          widget.badgeLabel,
                          style: GoogleFonts.outfit(
                            color: widget.accentColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spaceXS),
                  Text(
                    widget.subtitle,
                    style: GoogleFonts.inter(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppTheme.spaceSM),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
