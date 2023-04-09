part of 'spark_bloc.dart';

enum SparkStatus { loading, success }

class SparkState extends Equatable {
  SparkState({
    this.status = SparkStatus.loading,
    required this.appBarInformation,
  });

  final SparkStatus status;

  // App bar related state
  AppBarInformation appBarInformation = AppBarInformation();

  SparkState copyWith({
    SparkStatus? status,
    AppBarInformation? appBarInformation,
  }) {
    return SparkState(
      status: status ?? this.status,
      appBarInformation: appBarInformation ?? this.appBarInformation,
    );
  }

  @override
  String toString() => '''SparkState { status: $status, title: ${appBarInformation.title}, hidden: ${appBarInformation.hidden} }''';

  @override
  List<dynamic> get props => [status, appBarInformation];
}

class SparkInitial extends SparkState {
  SparkInitial() : super(appBarInformation: AppBarInformation());
}
