import 'package:test/test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:reddit/reddit.dart';
import 'package:spark/feed/bloc/feed_bloc.dart';

void main() {
  group('FeedBloc', () {
    late FeedBloc feedBloc;

    setUp(() async {
      await dotenv.load(fileName: ".env");
      Reddit reddit = Reddit(clientId: dotenv.env['REDDIT_CLIENT_ID']!, clientSecret: dotenv.env['REDDIT_CLIENT_SECRET']!, userAgent: dotenv.env['REDDIT_CLIENT_USER_AGENT']!);
      feedBloc = FeedBloc(reddit: reddit);
    });

    blocTest(
      'produces FeedStatus.failure when calling FeedRefreshed() with no parameters',
      build: () => feedBloc,
      act: (bloc) => bloc.add(FeedRefreshed()),
      expect: () => [
        const FeedState(status: FeedStatus.loading, posts: []),
        const FeedState(status: FeedStatus.failure, posts: []),
      ],
    );
  });
}
