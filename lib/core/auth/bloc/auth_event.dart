part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthChecked extends AuthEvent {
  AuthChecked();
}

class AuthLogout extends AuthEvent {
  AuthLogout();
}
