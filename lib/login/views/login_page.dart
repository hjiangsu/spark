import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final WebViewController _controller;

  Future<void> _initWebView() async {
    // Get device information
    final prefs = await SharedPreferences.getInstance();
    String? userUuid = prefs.getString('userUuid');

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      // ..setNavigationDelegate(
      //   NavigationDelegate(
      //     onPageFinished: (String url) {
      //       if (url.startsWith("${dotenv.get('REDDIT_CLIENT_CALLBACK_URL')}/auth")) {
      //         Navigator.maybePop(context);
      //       }
      //     },
      //   ),
      // )
      ..loadRequest(Uri.parse(
          "https://reddit.com/api/v1/authorize.compact?client_id=${dotenv.get('REDDIT_CLIENT_ID')}&response_type=code&state=$userUuid&redirect_uri=${dotenv.get('REDDIT_CLIENT_CALLBACK_URL')}&duration=permanent&scope=*"));

    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }
  }

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

    _controller = controller;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initWebView();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(child: WebViewWidget(controller: _controller)),
    );
  }
}
