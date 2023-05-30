// Flutter package imports
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// External package imports
import 'package:bloc/bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

// Spark package imports
import 'package:spark/app.dart';
import 'package:spark/core/debug/spark_bloc_observer.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Preserve the splash screen until the app is fully loaded
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Load up environment variables
  await dotenv.load(fileName: ".env");

  // Initialize bloc observer in debug mode
  if (kDebugMode) Bloc.observer = SparkBlocObserver();

  // Run application
  await SentryFlutter.init(
    (options) {
      options.dsn = kDebugMode ? '' : dotenv.env['SENTRY_DSN'];
      options.debug = kDebugMode;
    },
    appRunner: () => runApp(
      DefaultAssetBundle(
        bundle: SentryAssetBundle(),
        child: const App(),
      ),
    ),
  );
}
