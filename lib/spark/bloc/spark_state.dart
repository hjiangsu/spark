part of 'spark_bloc.dart';

enum SparkStatus { loading, success }

class SparkState extends Equatable {
  SparkState({
    this.status = SparkStatus.loading,
    required this.appBarInformation,
    this.activePage = AppMenu.feed,
  });

  final SparkStatus status;
  final AppMenu activePage;

  // App bar related state
  AppBarInformation appBarInformation = AppBarInformation();

  SparkState copyWith({
    SparkStatus? status,
    AppBarInformation? appBarInformation,
    AppMenu? activePage,
  }) {
    return SparkState(
      status: status ?? this.status,
      appBarInformation: appBarInformation ?? this.appBarInformation,
      activePage: activePage ?? this.activePage,
    );
  }

  @override
  String toString() => '''SparkState { status: $status, title: ${appBarInformation.title}, hidden: ${appBarInformation.hidden} }''';

  @override
  List<dynamic> get props => [status, appBarInformation, activePage];
}

class SparkInitial extends SparkState {
  SparkInitial() : super(appBarInformation: AppBarInformation(), activePage: AppMenu.feed);
}
