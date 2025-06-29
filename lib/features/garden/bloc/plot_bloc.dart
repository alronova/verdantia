import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/plot_model.dart';

part './plot_event.dart';
part './plot_state.dart';

class PlotBloc extends Bloc<PlotEvent, PlotState> {
  PlotBloc({required Plot plot}) : super(PlotState(plot: plot)) {
    on<WaterPlot>((event, emit) {
      emit(state.copyWith(isWatered: true));
      // call animation
    });
    on<ClearPlant>((event, emit) {
      emit(state.copyWith(plot: state.plot.copyWith(plantId: null)));
    });
  }
}
