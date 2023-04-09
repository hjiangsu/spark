part of 'spark_bloc.dart';

abstract class SparkEvent extends Equatable {
  const SparkEvent();

  @override
  List<Object> get props => [];
}

class AppBarTitleChanged extends SparkEvent {
  final String title;

  const AppBarTitleChanged({required this.title});
}

class AppBarVisibilityChanged extends SparkEvent {
  final bool hideAppBar;

  const AppBarVisibilityChanged({required this.hideAppBar});
}

class AppBarActionChanged extends SparkEvent {
  final List<Widget> actions;

  const AppBarActionChanged({required this.actions});
}
