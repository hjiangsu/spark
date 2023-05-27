// Flutter package imports
import 'package:flutter/material.dart';

// External package imports
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'spark_event.dart';
part 'spark_state.dart';

class SparkBloc extends Bloc<SparkEvent, SparkState> {
  SparkBloc() : super(const SparkState()) {
    on<ScaffoldKeyChanged>((event, emit) {
      emit(state.copyWith(status: SparkStatus.loading));
      emit(state.copyWith(status: SparkStatus.success, scaffoldKey: event.scaffoldKey));
    });

    on<FeedContextChanged>((event, emit) {
      if (state.feedContext == event.feedContext) {
        emit(state.copyWith(status: SparkStatus.success));
      } else {
        emit(state.copyWith(status: SparkStatus.loading));
        emit(state.copyWith(status: SparkStatus.success, feedContext: event.feedContext));
      }
    });
  }
}
