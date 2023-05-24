import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:pubnub/pubnub.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spark/core/auth/bloc/auth_bloc.dart';
import 'package:spark/feed/widgets/feed_drawer.dart';
import 'package:spark/spark/spark.dart';

import 'package:spark/widgets/bottom_app_bar/bottom_app_bar.dart';
import 'package:spark/widgets/error_message/error_message.dart';
import 'package:uuid/uuid.dart';

// const tabs = [
//   ScaffoldWithNavBarTabItem(
//     initialLocation: '/a',
//     icon: Icon(Icons.home),
//     label: 'Section A',
//   ),
//   ScaffoldWithNavBarTabItem(
//     initialLocation: '/b',
//     icon: Icon(Icons.settings),
//     label: 'Section B',
//   ),
// ];

class ScaffoldNavBar extends StatefulWidget {
  final Widget child;

  const ScaffoldNavBar({Key? key, required this.child}) : super(key: key);

  @override
  State<ScaffoldNavBar> createState() => _ScaffoldNavBarState();
}

class _ScaffoldNavBarState extends State<ScaffoldNavBar> {
  dynamic pubnub;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  Future<void> _initPubNub() async {
    Uuid uuid = const Uuid();

    // Get device information
    final prefs = await SharedPreferences.getInstance();
    String? userUuid = prefs.getString('userUuid');

    if (userUuid == null) {
      userUuid = uuid.v4();
      await prefs.setString('userUuid', userUuid);
    }

    // Initialize pubnub to be used to get notifications
    final keyset = Keyset(
      subscribeKey: dotenv.env['PUBNUB_SUBSCRIBE_KEY']!,
      publishKey: dotenv.env['PUBNUB_PUBLISH_KEY']!,
      userId: UserId(userUuid),
    );

    pubnub = PubNub(defaultKeyset: keyset);

    // Set up pubnub subscription
    Subscription subscription = pubnub.subscribe(channels: {userUuid});
    subscription.messages.listen((envelope) async {
      // Store the authorization information into local storage
      final prefs = await SharedPreferences.getInstance();
      String encodedAuthorizationMap = json.encode(envelope.payload);
      await prefs.setString('userAuthorization', encodedAuthorizationMap);

      context.read<AuthBloc>().add(AuthChecked());
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPubNub(); // Perform PubNub initialization
    });

    context.read<AuthBloc>().add(AuthChecked());
    context.read<SparkBloc>().add(ScaffoldKeyChanged(scaffoldKey: scaffoldKey));
  }

  @override
  Widget build(BuildContext context) {
    print(GoRouter.of(context).location);
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) => {
        if (state.status == AuthStatus.success) {GoRouter.of(context).go('/feed')}
      },
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return const Center(child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator()));
          case AuthStatus.success:
            FlutterNativeSplash.remove();
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
