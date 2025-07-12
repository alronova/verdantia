part of './plant_bloc.dart';

abstract class PlantEvent {}

class UpdatePlantAge extends PlantEvent {
  final String plantId;
  final int newAge;

  UpdatePlantAge(this.plantId, this.newAge);
}

class UpdatePlantDisease extends PlantEvent {
  final String plantId;
  final String disease;
  final int intensity;

  UpdatePlantDisease(this.plantId, this.disease, this.intensity);
}

class FetchUserPlants extends PlantEvent {
  final String userId;

  FetchUserPlants(this.userId);
}
