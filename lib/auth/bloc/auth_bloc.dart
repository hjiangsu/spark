import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:reddit/reddit.dart';

part 'auth_event.dart';
part 'auth_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.reddit}) : super(const AuthState()) {
    on<AuthChecked>(
      _onAuthChecked,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  final Reddit reddit;

  Future<void> _onAuthChecked(AuthChecked event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      // Retrieve any user authorization if it exists
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? encodedAuthorizationMap = prefs.getString('userAuthorization');
      Map<String, dynamic>? decodedAuthorizationMap = (encodedAuthorizationMap != null) ? json.decode(encodedAuthorizationMap) : null;

      if (decodedAuthorizationMap != null) {
        await reddit.authorization?.reauthorize(refreshCredentials: decodedAuthorizationMap);
      }

      Redditor user = await reddit.me();
      List<Subreddit> subscriptions = await user.subscriptions();

      emit(
        state.copyWith(
          status: decodedAuthorizationMap != null ? AuthStatus.success : AuthStatus.failure,
          isUserAuthorized: decodedAuthorizationMap != null,
          subscriptions: subscriptions,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.failure));
    }
  }
}
