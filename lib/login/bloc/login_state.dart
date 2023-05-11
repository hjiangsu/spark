part of 'login_bloc.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
  });

  final LoginStatus status;

  LoginState copyWith({
    required LoginStatus status,
  }) {
    return LoginState(
      status: status,
    );
  }

  @override
  String toString() => '''LoginState { status: $status''';

  @override
  List<dynamic> get props => [status];
}
