import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spark/app.dart';
import 'package:spark/singletons/reddit_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load up environment variables
  await dotenv.load(fileName: ".env");

  // Retrieve any previous user authorization if it exists
  final prefs = await SharedPreferences.getInstance();
  final String? encodedAuthorizationMap = prefs.getString('authorization');
  final Map<String, dynamic>? decodedAuthorizationMap = (encodedAuthorizationMap != null) ? json.decode(encodedAuthorizationMap) : null;

  // Initialize reddit library with any previous user authorization
  if (decodedAuthorizationMap != null) {
    await RedditClient.instance.authorize();
    RedditClient.instance.authorization?.setAuthorization(decodedAuthorizationMap);
  }

  runApp(const App());
}
