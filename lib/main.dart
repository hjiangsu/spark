import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:spark/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load up environment variables
  await dotenv.load(fileName: ".env");

  // Run application
  runApp(const App());
}
