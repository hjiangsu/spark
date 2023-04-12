import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:spark/core/enums/app_menu_options.dart';
import 'package:spark/core/models/appbar_information/appbar_information.dart';

part 'spark_event.dart';
part 'spark_state.dart';

class SparkBloc extends Bloc<SparkEvent, SparkState> {
  SparkBloc() : super(SparkInitial()) {
    on<AppBarTitleChanged>((event, emit) {
      emit(state.copyWith(status: SparkStatus.loading));

      if (event.title != state.appBarInformation.title) {
        emit(state.copyWith(
          status: SparkStatus.success,
          appBarInformation: AppBarInformation(title: event.title, hidden: state.appBarInformation.hidden),
        ));
      } else {
        emit(state.copyWith(status: SparkStatus.success));
      }
    });
    on<AppBarVisibilityChanged>((event, emit) {
      emit(state.copyWith(
        status: SparkStatus.success,
        appBarInformation: AppBarInformation(title: state.appBarInformation.title, hidden: event.hideAppBar),
      ));
    });
    on<AppBarActionChanged>((event, emit) {
      emit(state.copyWith(
        status: SparkStatus.success,
        appBarInformation: AppBarInformation(title: state.appBarInformation.title, hidden: state.appBarInformation.hidden, actions: event.actions),
      ));
    });
    on<ActivePageChanged>((event, emit) {
      emit(state.copyWith(
        status: SparkStatus.success,
        activePage: event.appMenu,
      ));
    });
  }
}
