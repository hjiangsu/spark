import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spark/core/auth/bloc/auth_bloc.dart';
import 'package:spark/core/services/authorization_server/authorization_server.dart';
import 'package:spark/feed/widgets/feed_drawer.dart';
import 'package:spark/core/spark/spark.dart';
import 'package:spark/splash/splash.dart';

import 'package:spark/widgets/bottom_app_bar/bottom_app_bar.dart';
import 'package:spark/widgets/error_message/error_message.dart';

class ScaffoldNavBar extends StatefulWidget {
  final Widget child;

  const ScaffoldNavBar({Key? key, required this.child}) : super(key: key);

  @override
  State<ScaffoldNavBar> createState() => _ScaffoldNavBarState();
}

class _ScaffoldNavBarState extends State<ScaffoldNavBar> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  void _initInternalServer() async {
    await initializeAuthorizationServer(context);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _initInternalServer());

    context.read<AuthBloc>().add(AuthChecked());
    context.read<SparkBloc>().add(ScaffoldKeyChanged(scaffoldKey: scaffoldKey));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) => {
        if (state.status == AuthStatus.success) {GoRouter.of(context).go('/feed')}
      },
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return const SplashPage(splashText: '');
          case AuthStatus.success:
            // FlutterNativeSplash.remove();
            return Scaffold(
              key: scaffoldKey,
              body: widget.child,
              drawer: GoRouter.of(context).location == '/feed' ? const FeedDrawer() : null,
              bottomNavigationBar: const ActionBar(),
            );
          case AuthStatus.failure:
            return const ErrorMessage(message: 'Something went wrong');
        }
      },
    );
  }
}
