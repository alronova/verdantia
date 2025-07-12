part of './plot_bloc.dart';

abstract class PlotEvent extends Equatable {
  const PlotEvent();

  @override
  List<Object?> get props => [];
}

class WaterPlot extends PlotEvent {}

class ClearPlant extends PlotEvent {}

class FertilizePlot extends PlotEvent {}

class SunlightPlot extends PlotEvent {}

class UnlockPlot extends PlotEvent {}

class UpdatePlotData extends PlotEvent {
  final Plot updatedPlot;

  const UpdatePlotData(this.updatedPlot);

  @override
  List<Object?> get props => [updatedPlot];
}
