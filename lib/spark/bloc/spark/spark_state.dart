part of 'spark_bloc.dart';

enum SparkStatus { loading, success }

class SparkState extends Equatable {
  const SparkState({
    this.status = SparkStatus.loading,
    this.hideAppBar = false,
    this.appBarTitle = '',
  });

  final SparkStatus status;

  // App bar related state
  final bool hideAppBar;
  final String appBarTitle;

  SparkState copyWith({
    SparkStatus? status,
    bool? hideAppBar,
    String? appBarTitle,
  }) {
    return SparkState(
      status: status ?? this.status,
      hideAppBar: hideAppBar ?? this.hideAppBar,
      appBarTitle: appBarTitle ?? this.appBarTitle,
    );
  }

  @override
  String toString() => '''SparkState { status: $status, appBarTitle: $appBarTitle }''';

  @override
  List<dynamic> get props => [status, appBarTitle];
}

class SparkInitial extends SparkState {}
