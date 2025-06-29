part of './garden_bloc.dart';

abstract class GardenEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadGarden extends GardenEvent {}

class UpdatePlot extends GardenEvent {
  final Plot plot;
  UpdatePlot(this.plot);

  @override
  List<Object> get props => [plot];
}

class UnlockPlot extends GardenEvent {
  final int index;
  UnlockPlot(this.index);

  @override
  List<Object?> get props => [index];
}
