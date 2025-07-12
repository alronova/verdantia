import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/plot_model.dart';
import '../../../core/services/plot_service.dart';

part './plot_event.dart';
part './plot_state.dart';

class PlotBloc extends Bloc<PlotEvent, PlotState> {
  final PlotService _plotService = PlotService();
  final String uid;

  PlotBloc({required Plot plot, required this.uid})
      : super(PlotState(plot: plot)) {
    on<WaterPlot>(_onWaterPlot);
    on<FertilizePlot>(_onFertilizePlot);
    on<SunlightPlot>(_onSunlightPlot);
    on<UnlockPlot>(_onUnlockPlot);
    on<ClearPlant>(_onClearPlant);
    on<UpdatePlotData>(_onUpdatePlotData);
  }

  Future<void> _onWaterPlot(WaterPlot event, Emitter<PlotState> emit) async {
    print('[PlotBloc] WaterPlot event received.');
    await _plotService.waterPlot(uid, state.plot.index);
    emit(state.copyWith(
      isWatered: true,
      plot: state.plot.copyWith(lastWater: Timestamp.now()),
    ));
  }

  Future<void> _onFertilizePlot(
      FertilizePlot event, Emitter<PlotState> emit) async {
    await _plotService.fertilizePlot(uid, state.plot.index);
    emit(state.copyWith(
      plot: state.plot.copyWith(lastFertilizer: Timestamp.now()),
    ));
  }

  Future<void> _onSunlightPlot(
      SunlightPlot event, Emitter<PlotState> emit) async {
    await _plotService.sunlightPlot(uid, state.plot.index);
    emit(state.copyWith(
      plot: state.plot.copyWith(lastSunlight: Timestamp.now()),
    ));
  }

  Future<void> _onUnlockPlot(UnlockPlot event, Emitter<PlotState> emit) async {
    await _plotService.unlockPlot(uid, state.plot.index);
    emit(state.copyWith(
      plot: state.plot.copyWith(unlocked: true),
    ));
  }

  Future<void> _onClearPlant(ClearPlant event, Emitter<PlotState> emit) async {
    await _plotService.assignPlantToPlot(uid, state.plot.index, "");
    emit(state.copyWith(
      plot: state.plot.copyWith(plantId: ""),
    ));
  }

  void _onUpdatePlotData(UpdatePlotData event, Emitter<PlotState> emit) {
    emit(state.copyWith(plot: event.updatedPlot));
  }
}
