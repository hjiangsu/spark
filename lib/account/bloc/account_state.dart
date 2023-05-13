part of 'account_bloc.dart';

enum AccountStatus { initial, loading, success, failure }

class AccountState extends Equatable {
  const AccountState({
    this.status = AccountStatus.initial,
    this.accountInformation,
  });

  final AccountStatus status;
  final RedditRedditor? accountInformation;

  AccountState copyWith({
    required AccountStatus status,
    RedditRedditor? accountInformation,
  }) {
    return AccountState(
      status: status,
      accountInformation: accountInformation,
    );
  }

  @override
  String toString() => '''AccountState { status: $status''';

  @override
  List<dynamic> get props => [status];
}
