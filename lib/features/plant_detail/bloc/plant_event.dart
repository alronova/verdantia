part of 'plant_bloc.dart';

abstract class PlantEvent extends Equatable {
  const PlantEvent();
  @override
  List<Object?> get props => [];
}

class LoadPlant extends PlantEvent {
  final String plantId;

  const LoadPlant(this.plantId);

  @override
  List<Object?> get props => [plantId];
}

class UpdatePlant extends PlantEvent {
  final Plant updatedPlant;

  const UpdatePlant(this.updatedPlant);

  @override
  List<Object?> get props => [updatedPlant];
}

class WaterPlant extends PlantEvent {}

class GiveSunlight extends PlantEvent {}
