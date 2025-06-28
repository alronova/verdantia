part of './garden_bloc.dart';

abstract class GardenState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GardenInitial extends GardenState {}

class GardenLoading extends GardenState {}

class GardenLoaded extends GardenState {
  final List<Plot> plots;
  GardenLoaded({required this.plots});

  @override
  List<Object?> get props => [plots];
}

class GardenError extends GardenState {
  final String message;
  GardenError({required this.message});

  @override
  List<Object?> get props => [message];
}
