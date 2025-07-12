import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verdantia/core/services/plant_service.dart';
import 'package:verdantia/data/models/plant_model.dart';
part './plant_event.dart';
part './plant_state.dart';

class PlantBloc extends Bloc<PlantEvent, PlantState> {
  final PlantService _plantService;

  PlantBloc(this._plantService) : super(PlantInitial()) {
    on<FetchUserPlants>(_onFetchUserPlants);
    on<UpdatePlantAge>(_onUpdateAge);
    on<UpdatePlantDisease>(_onUpdateDisease);
  }

  Future<void> _onFetchUserPlants(
      FetchUserPlants event, Emitter<PlantState> emit) async {
    emit(PlantLoading());
    try {
      final plants = await _plantService.fetchUserPlants(event.userId);
      emit(PlantLoaded(plants));
    } catch (e) {
      emit(PlantError('Failed to load plants: $e'));
    }
  }

  Future<void> _onUpdateAge(
      UpdatePlantAge event, Emitter<PlantState> emit) async {
    emit(PlantUpdating());
    try {
      await _plantService.updatePlantField(
        plantId: event.plantId,
        field: 'age',
        value: event.newAge,
      );
      emit(PlantUpdated());
    } catch (e) {
      emit(PlantUpdateError(e.toString()));
    }
  }

  Future<void> _onUpdateDisease(
      UpdatePlantDisease event, Emitter<PlantState> emit) async {
    emit(PlantUpdating());
    try {
      await _plantService.updatePlantFields(
        plantId: event.plantId,
        fields: {
          'disease': event.disease,
          'disease_intensity': event.intensity,
        },
      );
      emit(PlantUpdated());
    } catch (e) {
      emit(PlantUpdateError(e.toString()));
    }
  }
}
