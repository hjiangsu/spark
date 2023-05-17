import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:reddit/reddit.dart';

class RedditClient {
  RedditClient._();

  final reddit = Reddit(
    clientId: dotenv.env['REDDIT_CLIENT_ID']!,
    clientSecret: "",
    userAgent: dotenv.env['REDDIT_CLIENT_USER_AGENT']!,
    options: RedditOptions(callbackURL: "${dotenv.env['REDDIT_CLIENT_CALLBACK_URL']!}/refresh"),
  );

  static final instance = RedditClient._().reddit;
}
