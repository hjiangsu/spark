part of 'spark_bloc.dart';

enum SparkStatus { initial, loading, success, failure }

class SparkState extends Equatable {
  const SparkState({
    this.status = SparkStatus.initial,
    this.scaffoldKey,
    this.feedContext,
  });

  final SparkStatus status;

  /// The feed context is kept in the state in order for it to be referenced in the app drawer
  final BuildContext? feedContext;

  /// The scaffold key is kept in the state in order for the feed page to access the app scaffold
  final GlobalKey<ScaffoldState>? scaffoldKey;

  SparkState copyWith({
    SparkStatus? status,
    BuildContext? feedContext,
    GlobalKey<ScaffoldState>? scaffoldKey,
  }) {
    return SparkState(
      status: status ?? this.status,
      feedContext: feedContext ?? this.feedContext,
      scaffoldKey: scaffoldKey ?? this.scaffoldKey,
    );
  }

  @override
  String toString() => '''SparkState { status: $status }''';

  @override
  List<dynamic> get props => [status, scaffoldKey, feedContext];
}
