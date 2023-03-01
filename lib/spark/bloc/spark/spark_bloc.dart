import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'spark_event.dart';
part 'spark_state.dart';

class SparkBloc extends Bloc<SparkEvent, SparkState> {
  SparkBloc() : super(SparkInitial()) {
    on<AppBarTitleChanged>((event, emit) {
      emit(state.copyWith(status: SparkStatus.loading));

      if (event.title != state.appBarTitle) {
        emit(state.copyWith(status: SparkStatus.success, appBarTitle: event.title));
      } else {
        emit(state.copyWith(status: SparkStatus.success));
      }
    });
    on<AppBarVisibilityChanged>((event, emit) {
      emit(state.copyWith(status: SparkStatus.success, hideAppBar: event.hideAppBar));
    });
  }
}
