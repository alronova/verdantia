part of 'plant_bloc.dart';

abstract class PlantState extends Equatable {
  const PlantState();

  @override
  List<Object?> get props => [];
}

class PlantInitial extends PlantState {}

class PlantLoading extends PlantState {}

class PlantLoaded extends PlantState {
  final Plant plant;

  const PlantLoaded({required this.plant});

  @override
  List<Object?> get props => [plant];
}

class PlantError extends PlantState {
  final String message;

  const PlantError({required this.message});

  @override
  List<Object?> get props => [message];
}
