import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:pubnub/pubnub.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spark/feed/feed.dart';
import 'package:spark/enums/app_menu_options.dart';
// import 'package:spark/account/account.dart';
// import 'package:spark/settings/settings.dart';
import 'package:spark/auth/bloc/auth_bloc.dart';
import 'package:spark/widgets/bottom_app_bar/bottom_app_bar.dart';

class Spark extends StatefulWidget {
  const Spark({super.key});

  @override
  State<Spark> createState() => _SparkState();
}

class _SparkState extends State<Spark> {
  dynamic pubnub;

  AppMenu currentRoute = AppMenu.feed;

  // Scaffold app bar
  bool _hideAppBar = false;
  String _appBarTitle = '';
  List<Widget>? _appBarActions;

  // Scaffold drawer
  Widget? _drawer;

  // Scaffold FAB
  Widget? _floatingActionButton;
  FloatingActionButtonLocation _floatingActionButtonLocation = FloatingActionButtonLocation.centerDocked;

  Future<void> _initPubNub() async {
    // Get device information
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    dynamic deviceInfo = await deviceInfoPlugin.deviceInfo;

    // Initialize pubnub to be used to get notifications
    final keyset = Keyset(
      subscribeKey: dotenv.env['PUBNUB_SUBSCRIBE_KEY']!,
      publishKey: dotenv.env['PUBNUB_PUBLISH_KEY']!,
      userId: UserId(deviceInfo.identifierForVendor),
    );

    pubnub = PubNub(defaultKeyset: keyset);

    // Set up pubnub subscription
    Subscription subscription = pubnub.subscribe(channels: {'hjiangsu'});
    subscription.messages.listen((envelope) async {
      print('${envelope.uuid} sent a message: ${envelope.payload}');

      // Store the authorization information into local storage
      final prefs = await SharedPreferences.getInstance();
      String encodedAuthorizationMap = json.encode(envelope.payload);
      await prefs.setString('authorization', encodedAuthorizationMap);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User sucessfully authenticated')),
      );
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPubNub(); // Perform PubNub initialization
    });

    context.read<AuthBloc>().add(AuthChecked());
  }

  /// Updates the current route based off the selected navigation
  void updateRoute(AppMenu route) {
    if (currentRoute != route) {
      setState(() => currentRoute = route);
    }
  }

  // Update app bar related state
  updateAppBar(bool? hideAppBar, String? appBarTitle, List<Widget>? appBarActions) {
    setState(() {
      _hideAppBar = hideAppBar ?? _hideAppBar;
      _appBarTitle = appBarTitle ?? _appBarTitle;
      _appBarActions = appBarActions ?? _appBarActions;
    });
  }

  // Update drawer related state
  updateDrawer(Widget? drawer) {
    setState(() => _drawer = drawer);
  }

  // Update FAB related state
  updateFloatActionButton(Widget? floatingActionButton, FloatingActionButtonLocation? floatingActionButtonLocation) {
    setState(() {
      _floatingActionButton = floatingActionButton;
      _floatingActionButtonLocation = floatingActionButtonLocation ?? _floatingActionButtonLocation;
    });
  }

  /// Determines the body of the Scaffold based on the current route (bottomNavigationBar)
  Widget getBodyWidget() {
    switch (currentRoute) {
      case AppMenu.feed:
        return FeedPage(
            // onAppBarChanged: ({bool? hideAppBar, String? appBarTitle, List<Widget>? appBarActions}) {
            //   Future.delayed(Duration.zero, () => updateAppBar(hideAppBar, appBarTitle, appBarActions));
            // },
            // onFABChanged: ({Widget? floatingActionButton, FloatingActionButtonLocation? floatingActionButtonLocation}) {
            //   Future.delayed(Duration.zero, () => updateFloatActionButton(floatingActionButton, floatingActionButtonLocation));
            // },
            // onDrawerChanged: ({Widget? drawer}) {
            //   Future.delayed(Duration.zero, () => updateDrawer(drawer));
            // },
            );
      // case AppMenu.account:
      //   return AccountPage(
      //     onAppBarChanged: ({bool? hideAppBar, String? appBarTitle, List<Widget>? appBarActions}) {
      //       Future.delayed(Duration.zero, () => updateAppBar(hideAppBar, appBarTitle, appBarActions));
      //     },
      //   );
      // case AppMenu.settings:
      //   return SettingsPage(
      //     onAppBarChanged: ({bool? hideAppBar, String? appBarTitle, List<Widget>? appBarActions}) {
      //       Future.delayed(Duration.zero, () => updateAppBar(hideAppBar, appBarTitle, appBarActions));
      //     },
      //     onFABChanged: ({Widget? floatingActionButton, FloatingActionButtonLocation? floatingActionButtonLocation}) {
      //       Future.delayed(Duration.zero, () => updateFloatActionButton(floatingActionButton, floatingActionButtonLocation));
      //     },
      //     onDrawerChanged: ({Widget? drawer}) {
      //       Future.delayed(Duration.zero, () => updateDrawer(drawer));
      //     },
      //   );
      default:
        return Container();
    }
  }

  /// Generates a Text widget based on the appBarTitle
  /// Although the title parameter accepts a Widget, our use-case will be restricted to text
  Widget getAppBarTitle() {
    return AutoSizeText(_appBarTitle, maxLines: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _hideAppBar == true ? null : AppBar(toolbarHeight: 70.0, centerTitle: false, title: getAppBarTitle(), actions: _appBarActions),
        body: getBodyWidget(),
        drawer: _drawer,
        floatingActionButton: _floatingActionButton,
        floatingActionButtonLocation: _floatingActionButtonLocation,
        bottomNavigationBar: ActionBar(onRouteChange: (route) => updateRoute(route)));
  }
}
