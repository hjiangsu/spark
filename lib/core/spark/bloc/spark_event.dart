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

class FeedContextChanged extends SparkEvent {
  final BuildContext feedContext;

  const FeedContextChanged({required this.feedContext});
}

class RateLimitChanged extends SparkEvent {
  final int rateLimitUsage;

  const RateLimitChanged({required this.rateLimitUsage});
}

class FeedScrollControllerChanged extends SparkEvent {
  final ScrollController? scrollController;

  const FeedScrollControllerChanged({this.scrollController});
}
