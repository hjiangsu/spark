part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  @override
  List<Object> get props => [];
}

/// Event to be called when attempting to login
class LoginTriggered extends LoginEvent {}
