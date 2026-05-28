import 'package:flutter/material.dart';

import 'package:crownpass/features/splash/page/splash_page.dart';
import 'package:crownpass/features/home/page/home_page.dart';
import 'package:crownpass/features/mode_select/page/mode_select_page.dart';
import 'package:crownpass/features/game_setup/page/game_setup_page.dart';
import 'package:crownpass/features/vs_setup/page/vs_setup_page.dart';
import 'package:crownpass/features/game_table/page/game_table_page.dart';
import 'package:crownpass/features/round_settlement/page/round_settlement_page.dart';
import 'package:crownpass/features/sim_table/page/sim_table_page.dart';
import 'package:crownpass/features/sim_settlement/page/sim_settlement_page.dart';
import 'package:crownpass/features/history/page/history_page.dart';
import 'package:crownpass/features/statistics/page/statistics_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String home = '/home';
  static const String modeSelect = '/mode-select';
  static const String gameSetup = '/game-setup';
  static const String vsSetup = '/vs-setup';
  static const String gameTable = '/game-table';
  static const String roundSettlement = '/round-settlement';
  static const String simTable = '/sim-table';
  static const String simSettlement = '/sim-settlement';
  static const String history = '/history';
  static const String statistics = '/statistics';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fade(const SplashPage(), settings);
      case home:
        return _slide(const HomePage(), settings);
      case modeSelect:
        return _slide(const ModeSelectPage(), settings);
      case gameSetup:
        return _slide(const GameSetupPage(), settings);
      case vsSetup:
        return _slide(const VsSetupPage(), settings);
      case gameTable:
        return _slide(const GameTablePage(), settings);
      case roundSettlement:
        return _slide(const RoundSettlementPage(), settings);
      case simTable:
        return _slide(const SimTablePage(), settings);
      case simSettlement:
        return _slide(const SimSettlementPage(), settings);
      case history:
        return _slide(const HistoryPage(), settings);
      case statistics:
        return _slide(const StatisticsPage(), settings);
      default:
        return _fade(const HomePage(), settings);
    }
  }

  static PageRouteBuilder _fade(Widget page, RouteSettings settings) =>
      PageRouteBuilder(
        settings: settings,
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      );

  static PageRouteBuilder _slide(Widget page, RouteSettings settings) =>
      PageRouteBuilder(
        settings: settings,
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(
              position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      );
}
