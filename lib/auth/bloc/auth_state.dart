part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, success, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.isUserAuthorized = false,
    this.subscriptions,
  });

  final AuthStatus status;
  final bool isUserAuthorized;
  final List<dynamic>? subscriptions;

  AuthState copyWith({
    AuthStatus? status,
    bool? isUserAuthorized,
    List<dynamic>? subscriptions,
  }) {
    return AuthState(
      status: status ?? this.status,
      isUserAuthorized: isUserAuthorized ?? this.isUserAuthorized,
      subscriptions: subscriptions ?? this.subscriptions,
    );
  }

  @override
  String toString() => '''AuthState { status: $status, isUserAuthorized: $isUserAuthorized, subscriptions: ${subscriptions?.length} }''';

  @override
  List<dynamic> get props => [status, isUserAuthorized, subscriptions];
}
