import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:crownpass/app/router.dart';
import 'package:crownpass/app/theme.dart';
import 'package:crownpass/core/constants/app_constants.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleIn;
  late final Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _scaleIn = Tween(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _taglineFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRouter.home);
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppTheme.background,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                left: -72,
                top: -48,
                child: _SplashCircle(
                  size: 180,
                  color: AppTheme.teal.withValues(alpha: 0.18),
                ),
              ),
              Positioned(
                right: -58,
                bottom: 70,
                child: _SplashCircle(
                  size: 150,
                  color: AppTheme.gold.withValues(alpha: 0.22),
                ),
              ),
              Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppTheme.spaceLG),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (_, __) => FadeTransition(
                          opacity: _fadeIn,
                          child: ScaleTransition(
                            scale: _scaleIn,
                            child: Container(
                              width: 156,
                              height: 156,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.cardSurface,
                                border: Border.all(
                                  color: AppTheme.cardBorder,
                                  width: 3,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppTheme.cardBorder,
                                    blurRadius: 0,
                                    offset: Offset(6, 6),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/app_logo.png',
                                  fit: BoxFit.cover,
                                  semanticLabel: AppConstants.appName,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceLG),
                      FadeTransition(
                        opacity: _fadeIn,
                        child: Text(
                          AppConstants.appName,
                          style: GoogleFonts.outfit(
                            color: AppTheme.textPrimary,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceSM),
                      FadeTransition(
                        opacity: _taglineFade,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.teal.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusRound),
                            border: Border.all(
                              color: AppTheme.cardBorder,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            AppConstants.appSubtitle.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: AppTheme.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceMD),
                      // FadeTransition(
                      //   opacity: _taglineFade,
                      //   child: Text(
                      //     AppConstants.appTagline,
                      //     style: GoogleFonts.inter(
                      //       color: AppTheme.textSecondary,
                      //       fontSize: 14,
                      //       fontWeight: FontWeight.w700,
                      //     ),
                      //     textAlign: TextAlign.center,
                      //   ),
                      // ),
                      const SizedBox(height: AppTheme.spaceXL),
                      FadeTransition(
                        opacity: _taglineFade,
                        child: SizedBox(
                          width: 72,
                          child: LinearProgressIndicator(
                            backgroundColor: AppTheme.cardBorder,
                            valueColor:
                                const AlwaysStoppedAnimation(AppTheme.gold),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusRound),
                            minHeight: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Positioned(
              //   left: 0,
              //   right: 0,
              //   bottom: AppTheme.spaceLG,
              //   child: FadeTransition(
              //     opacity: _taglineFade,
              //     child: Center(
              //       child: Container(
              //         width: 112,
              //         height: 10,
              //         decoration: BoxDecoration(
              //           color: AppTheme.tableSurface,
              //           borderRadius:
              //               BorderRadius.circular(AppTheme.radiusRound),
              //           border: Border.all(color: AppTheme.cardBorder),
              //         ),
              //       ),
              //     ),
              // ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _SplashCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
