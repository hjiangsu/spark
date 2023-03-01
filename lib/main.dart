import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:spark/app.dart';
import 'package:spark/debug/spark_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load up environment variables
  await dotenv.load(fileName: ".env");

  // Bloc observer
  Bloc.observer = SparkBlocObserver();

  // Run application
  runApp(const App());
}
