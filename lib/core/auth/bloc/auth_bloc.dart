import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:reddit/reddit.dart';
import 'package:uuid/uuid.dart';

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
    on<AuthLogout>(
      _onAuthLogOut,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  final Reddit reddit;

  Future<void> _onAuthChecked(AuthChecked event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      // Retrieve user uuid
      final prefs = await SharedPreferences.getInstance();
      String? userUuid = prefs.getString('userUuid');

      if (userUuid == null || userUuid.isEmpty) {
        // Generate a user uuid
        Uuid uuid = const Uuid();
        userUuid = uuid.v4();

        // Set the userUuid to local storage
        await prefs.setString('userUuid', userUuid);
      }

      // First, perform anonymous authorization with Reddit
      await reddit.authorize(userUuid: userUuid);

      // Retrieve any user authorization if it exists
      String? encodedAuthorizationMap = prefs.getString('userAuthorization');
      Map<String, dynamic>? decodedAuthorizationMap = (encodedAuthorizationMap != null) ? json.decode(encodedAuthorizationMap) : null;

      // Re-authenticate with user token if provided
      if (decodedAuthorizationMap != null) {
        await reddit.authorization?.reauthorize(refreshCredentials: decodedAuthorizationMap);

        int now = DateTime.now().millisecondsSinceEpoch;
        int expiration = decodedAuthorizationMap['expires_at_ms'];

        if (now > expiration) {
          await reddit.authorization?.reauthorize(refreshCredentials: decodedAuthorizationMap);
        } else {
          await reddit.authorization?.setAuthorization(decodedAuthorizationMap);
        }
      }

      List<Subreddit> subscriptions = [];

      if (reddit.authorization != null && reddit.authorization!.isUserAuthenticated) {
        Redditor user = await reddit.me();
        subscriptions = await user.subscriptions();
      }

      await Future.delayed(const Duration(seconds: 1));
      emit(
        state.copyWith(
          status: AuthStatus.success,
          isUserAuthorized: reddit.authorization?.isUserAuthenticated ?? false,
          subscriptions: subscriptions,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(status: AuthStatus.failure));
      Sentry.captureException(e, stackTrace: s);
    }
  }

  Future<void> _onAuthLogOut(AuthLogout event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('userAuthorization'); // Remove user authorization

      String? userUuid = prefs.getString('userUuid');

      if (userUuid == null || userUuid.isEmpty) {
        // Generate a user uuid
        Uuid uuid = const Uuid();
        userUuid = uuid.v4();

        // Set the userUuid to local storage
        await prefs.setString('userUuid', userUuid);
      }

      // First, perform anonymous authorization with Reddit
      await reddit.authorize(userUuid: userUuid);

      List<Subreddit> subscriptions = [];

      if (reddit.authorization != null && reddit.authorization!.isUserAuthenticated) {
        Redditor user = await reddit.me();
        subscriptions = await user.subscriptions();
      }

      await Future.delayed(const Duration(seconds: 1));

      emit(
        state.copyWith(
          status: AuthStatus.success,
          isUserAuthorized: reddit.authorization?.isUserAuthenticated ?? false,
          subscriptions: subscriptions,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(status: AuthStatus.failure));
      Sentry.captureException(e, stackTrace: s);
    }
  }
}
