part of 'spark_bloc.dart';

enum SparkStatus { initial, loading, success, failure }

class SparkState extends Equatable {
  const SparkState({
    this.status = SparkStatus.initial,
    this.scaffoldKey,
    this.feedContext,
  });

  final SparkStatus status;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final BuildContext? feedContext;

  SparkState copyWith({
    SparkStatus? status,
    GlobalKey<ScaffoldState>? scaffoldKey,
    BuildContext? feedContext,
  }) {
    return SparkState(
      status: status ?? this.status,
      scaffoldKey: scaffoldKey ?? this.scaffoldKey,
      feedContext: feedContext ?? this.feedContext,
    );
  }

  @override
  String toString() => '''SparkState { status: $status }''';

  @override
  List<dynamic> get props => [status, scaffoldKey, feedContext];
}
