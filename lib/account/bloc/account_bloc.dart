import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:spark/core/models/reddit_redditor/reddit_redditor.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:reddit/reddit.dart';

part 'account_event.dart';
part 'account_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc({required this.reddit}) : super(const AccountState()) {
    on<AccountFetched>(
      _onAccountFetched,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  final Reddit reddit;

  /// Call this function when fetching account
  Future<void> _onAccountFetched(AccountFetched event, Emitter<AccountState> emit) async {
    try {
      if (event.isUserAuthorized) {
        Redditor redditor = await reddit.me();

        emit(state.copyWith(
          status: AccountStatus.success,
          accountInformation: RedditRedditor(
            id: redditor.information!['id'],
            avatarImageURL: redditor.information!['snoovatar_img'],
            avatarIconImageURL: HtmlUnescape().convert(redditor.information!['icon_img']),
            linkKarma: redditor.information!['link_karma'],
            totalKarma: redditor.information!['total_karma'],
            name: redditor.information!['name'],
            createdAt: redditor.information!['created_utc'].toInt(),
          ),
        ));
      } else {
        emit(state.copyWith(status: AccountStatus.failure));
      }
    } catch (e, s) {
      emit(state.copyWith(status: AccountStatus.failure));
      Sentry.captureException(e, stackTrace: s);
    }
  }
}
