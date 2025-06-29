part of './plot_bloc.dart';

abstract class PlotEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class WaterPlot extends PlotEvent {}

class ClearPlant extends PlotEvent {}
