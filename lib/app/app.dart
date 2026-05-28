import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:crownpass/app/router.dart';
import 'package:crownpass/app/theme.dart';
import 'package:crownpass/features/game_table/bloc/game_table_bloc.dart';
import 'package:crownpass/features/sim_table/bloc/sim_table_bloc.dart';

class CrownPassApp extends StatelessWidget {
  const CrownPassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GameTableBloc>(
          create: (_) => GameTableBloc(),
        ),
        BlocProvider<SimTableBloc>(
          create: (_) => SimTableBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Domino Hansip',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: AppRouter.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
