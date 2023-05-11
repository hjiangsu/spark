import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:reddit/reddit.dart';

part 'login_event.dart';
part 'login_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required this.reddit}) : super(const LoginState()) {
    on<LoginTriggered>(
      _onLoginTriggered,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  final Reddit reddit;

  /// Call this function to perform a login action.
  Future<void> _onLoginTriggered(LoginTriggered event, Emitter<LoginState> emit) async {
    try {
      return emit(state.copyWith(status: LoginStatus.success));
    } catch (e, s) {
      emit(state.copyWith(status: LoginStatus.failure));
      Sentry.captureException(e, stackTrace: s);
    }
  }
}
