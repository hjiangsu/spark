import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:spark/app.dart';
import 'package:spark/core/debug/spark_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load up environment variables
  await dotenv.load(fileName: ".env");

  // Bloc observer
  Bloc.observer = SparkBlocObserver();

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
