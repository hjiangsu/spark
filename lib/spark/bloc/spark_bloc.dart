import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'spark_event.dart';
part 'spark_state.dart';

class SparkBloc extends Bloc<SparkEvent, SparkState> {
  SparkBloc(super.initialState) {
    on<ScaffoldKeyChanged>((event, emit) {
      emit(state.copyWith(status: SparkStatus.loading));
      emit(state.copyWith(status: SparkStatus.success, scaffoldKey: event.scaffoldKey));
    });
  }
}
