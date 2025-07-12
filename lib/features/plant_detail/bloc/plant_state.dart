part of './plant_bloc.dart';

abstract class PlantState {}

class PlantInitial extends PlantState {}

class PlantUpdating extends PlantState {}

class PlantUpdated extends PlantState {}

class PlantUpdateError extends PlantState {
  final String message;

  PlantUpdateError(this.message);
}

class PlantLoading extends PlantState {}

class PlantLoaded extends PlantState {
  final List<Plant> plants;

  PlantLoaded(this.plants);
}

class PlantError extends PlantState {
  final String message;

  PlantError(this.message);
}
