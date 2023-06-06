// Flutter package imports
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// External package imports
import 'package:bloc/bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// Spark package imports
import 'package:spark/app.dart';
import 'package:spark/core/debug/spark_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load up environment variables
  await dotenv.load(fileName: ".env");
  String? sentryDSN = dotenv.env['SENTRY_DSN'];

  // Initialize bloc observer in debug mode
  if (kDebugMode) Bloc.observer = SparkBlocObserver();

  // Run application
  if (sentryDSN == null || sentryDSN.isEmpty) {
    // If Sentry is not detected, continue without Sentry support
    runApp(const App());
  } else {
    await SentryFlutter.init(
      (options) {
        options.dsn = kDebugMode ? '' : sentryDSN;
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
}
