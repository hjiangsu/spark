import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spark/spark.dart';
import 'package:spark/theme/bloc/theme_bloc.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad};
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (context) => ThemeBloc()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          switch (state.status) {
            case ThemeStatus.loading:
              context.read<ThemeBloc>().add(ThemeRefreshed());
              return const Center(child: CircularProgressIndicator());
            case ThemeStatus.success:
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                themeMode: state.useDarkTheme ? ThemeMode.dark : ThemeMode.light,
                scrollBehavior: CustomScrollBehavior(),
                theme: ThemeData(
                  useMaterial3: true,
                  brightness: Brightness.light,
                  colorSchemeSeed: state.colorSchemeSeed,
                ),
                darkTheme: ThemeData(
                  useMaterial3: true,
                  brightness: Brightness.dark,
                  colorSchemeSeed: state.colorSchemeSeed,
                ),
                home: const Spark(),
              );
            case ThemeStatus.failure:
              return Container();
          }
        },
      ),
    );
  }
}
