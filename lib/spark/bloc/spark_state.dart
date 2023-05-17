part of 'spark_bloc.dart';

enum SparkStatus { initial, loading, success, failure }

class SparkState extends Equatable {
  const SparkState({
    this.status = SparkStatus.initial,
    this.scaffoldKey,
  });

  final SparkStatus status;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  SparkState copyWith({
    SparkStatus? status,
    GlobalKey<ScaffoldState>? scaffoldKey,
  }) {
    return SparkState(
      status: status ?? this.status,
      scaffoldKey: scaffoldKey ?? this.scaffoldKey,
    );
  }

  @override
  String toString() => '''SparkState { status: $status }''';

  @override
  List<dynamic> get props => [status, scaffoldKey];
}
