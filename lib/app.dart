import 'dart:ui';

// Flutter package imports
import 'package:flutter/material.dart';

// External package imports
import 'package:flutter_bloc/flutter_bloc.dart';

// Spark package imports
import 'package:spark/router.dart';
import 'package:spark/core/spark/bloc/spark_bloc.dart';
import 'package:spark/core/auth/bloc/auth_bloc.dart';
import 'package:spark/core/theme/bloc/theme_bloc.dart';
import 'package:spark/core/singletons/reddit_client.dart';

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
    final theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (context) => ThemeBloc()),
        BlocProvider<SparkBloc>(create: (context) => SparkBloc()),
        BlocProvider<AuthBloc>(create: (context) => AuthBloc(reddit: RedditClient.instance)),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          switch (state.status) {
            case ThemeStatus.loading:
              context.read<ThemeBloc>().add(ThemeRefreshed());
              return Container(color: const Color.fromRGBO(18, 18, 18, 1));
            case ThemeStatus.success:
              return MaterialApp.router(
                routerConfig: router,
                debugShowCheckedModeBanner: false,
                scrollBehavior: CustomScrollBehavior(),
                themeMode: state.useDarkTheme ? ThemeMode.dark : ThemeMode.light,
                theme: ThemeData(
                  useMaterial3: true,
                  brightness: Brightness.light,
                  colorSchemeSeed: state.colorSchemeSeed,
                  textTheme: Typography.blackCupertino.copyWith(
                    bodySmall: Typography.blackCupertino.bodySmall?.copyWith(fontSize: theme.textTheme.bodySmall!.fontSize! * state.fontSizeScale),
                    bodyMedium: Typography.blackCupertino.bodyMedium?.copyWith(fontSize: theme.textTheme.bodyMedium!.fontSize! * state.fontSizeScale),
                    bodyLarge: Typography.blackCupertino.bodyLarge?.copyWith(fontSize: theme.textTheme.bodyLarge!.fontSize! * state.fontSizeScale),
                    labelSmall: Typography.blackCupertino.labelSmall?.copyWith(fontSize: theme.textTheme.labelSmall!.fontSize! * state.fontSizeScale),
                    labelMedium: Typography.blackCupertino.labelMedium?.copyWith(fontSize: theme.textTheme.labelMedium!.fontSize! * state.fontSizeScale),
                    labelLarge: Typography.blackCupertino.labelLarge?.copyWith(fontSize: theme.textTheme.labelLarge!.fontSize! * state.fontSizeScale),
                    titleSmall: Typography.blackCupertino.titleSmall?.copyWith(fontSize: theme.textTheme.titleSmall!.fontSize! * state.fontSizeScale),
                    titleMedium: Typography.blackCupertino.titleMedium?.copyWith(fontSize: theme.textTheme.titleMedium!.fontSize! * state.fontSizeScale),
                    titleLarge: Typography.blackCupertino.titleLarge?.copyWith(fontSize: theme.textTheme.titleLarge!.fontSize! * state.fontSizeScale),
                    headlineSmall: Typography.blackCupertino.headlineSmall?.copyWith(fontSize: theme.textTheme.headlineSmall!.fontSize! * state.fontSizeScale),
                    headlineMedium: Typography.blackCupertino.headlineMedium?.copyWith(fontSize: theme.textTheme.headlineMedium!.fontSize! * state.fontSizeScale),
                    headlineLarge: Typography.blackCupertino.headlineLarge?.copyWith(fontSize: theme.textTheme.headlineLarge!.fontSize! * state.fontSizeScale),
                    displaySmall: Typography.blackCupertino.displaySmall?.copyWith(fontSize: theme.textTheme.displaySmall!.fontSize! * state.fontSizeScale),
                    displayMedium: Typography.blackCupertino.displayMedium?.copyWith(fontSize: theme.textTheme.displayMedium!.fontSize! * state.fontSizeScale),
                    displayLarge: Typography.blackCupertino.displayLarge?.copyWith(fontSize: theme.textTheme.displayLarge!.fontSize! * state.fontSizeScale),
                  ),
                ),
                darkTheme: ThemeData(
                  useMaterial3: true,
                  brightness: Brightness.dark,
                  colorSchemeSeed: state.colorSchemeSeed,
                  textTheme: Typography.whiteCupertino.copyWith(
                    bodySmall: Typography.whiteCupertino.bodySmall?.copyWith(fontSize: theme.textTheme.bodySmall!.fontSize! * state.fontSizeScale),
                    bodyMedium: Typography.whiteCupertino.bodyMedium?.copyWith(fontSize: theme.textTheme.bodyMedium!.fontSize! * state.fontSizeScale),
                    bodyLarge: Typography.whiteCupertino.bodyLarge?.copyWith(fontSize: theme.textTheme.bodyLarge!.fontSize! * state.fontSizeScale),
                    labelSmall: Typography.whiteCupertino.labelSmall?.copyWith(fontSize: theme.textTheme.labelSmall!.fontSize! * state.fontSizeScale),
                    labelMedium: Typography.whiteCupertino.labelMedium?.copyWith(fontSize: theme.textTheme.labelMedium!.fontSize! * state.fontSizeScale),
                    labelLarge: Typography.whiteCupertino.labelLarge?.copyWith(fontSize: theme.textTheme.labelLarge!.fontSize! * state.fontSizeScale),
                    titleSmall: Typography.whiteCupertino.titleSmall?.copyWith(fontSize: theme.textTheme.titleSmall!.fontSize! * state.fontSizeScale),
                    titleMedium: Typography.whiteCupertino.titleMedium?.copyWith(fontSize: theme.textTheme.titleMedium!.fontSize! * state.fontSizeScale),
                    titleLarge: Typography.whiteCupertino.titleLarge?.copyWith(fontSize: theme.textTheme.titleLarge!.fontSize! * state.fontSizeScale),
                    headlineSmall: Typography.whiteCupertino.headlineSmall?.copyWith(fontSize: theme.textTheme.headlineSmall!.fontSize! * state.fontSizeScale),
                    headlineMedium: Typography.whiteCupertino.headlineMedium?.copyWith(fontSize: theme.textTheme.headlineMedium!.fontSize! * state.fontSizeScale),
                    headlineLarge: Typography.whiteCupertino.headlineLarge?.copyWith(fontSize: theme.textTheme.headlineLarge!.fontSize! * state.fontSizeScale),
                    displaySmall: Typography.whiteCupertino.displaySmall?.copyWith(fontSize: theme.textTheme.displaySmall!.fontSize! * state.fontSizeScale),
                    displayMedium: Typography.whiteCupertino.displayMedium?.copyWith(fontSize: theme.textTheme.displayMedium!.fontSize! * state.fontSizeScale),
                    displayLarge: Typography.whiteCupertino.displayLarge?.copyWith(fontSize: theme.textTheme.displayLarge!.fontSize! * state.fontSizeScale),
                  ),
                ),
              );
            case ThemeStatus.failure:
              return Container();
          }
        },
      ),
    );
  }
}
