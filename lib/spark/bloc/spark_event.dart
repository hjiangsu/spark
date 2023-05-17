part of 'spark_bloc.dart';

abstract class SparkEvent extends Equatable {
  const SparkEvent();

  @override
  List<Object> get props => [];
}

class ScaffoldKeyChanged extends SparkEvent {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ScaffoldKeyChanged({required this.scaffoldKey});
}
