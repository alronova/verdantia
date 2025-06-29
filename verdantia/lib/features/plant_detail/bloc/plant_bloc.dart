// === bloc/plant_bloc.dart ===
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/plant_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'plant_event.dart';
part 'plant_state.dart';

class PlantBloc extends Bloc<PlantEvent, PlantState> {
  final String plantId;
  PlantBloc({required this.plantId}) : super(PlantInitial()) {
    on<LoadPlant>(_onLoadPlant);
    on<UpdatePlant>(_onUpdatePlant);
    on<WaterPlant>(_onWaterPlant);
    on<GiveSunlight>(_onGiveSunlight);
  }

  final _firestore = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _onLoadPlant(LoadPlant event, Emitter<PlantState> emit) async {
    emit(PlantLoading());
    try {
      // firebase as placeholder but the actual plant will come from mongodb
      final doc = await _firestore.collection('plants').doc(plantId).get();
      final data = doc.data();
      if (data == null) throw Exception("Plant not found");

      final plant = Plant.fromJson(data);
      emit(PlantLoaded(plant: plant));
    } catch (e) {
      emit(PlantError(message: e.toString()));
    }
  }

  Future<void> _onUpdatePlant(
      UpdatePlant event, Emitter<PlantState> emit) async {
    try {
      await _firestore
          .collection('plants')
          .doc(plantId)
          .update(event.updatedPlant.toJson());
      // Optional: Trigger Java sprite generator here with updated plant
      // Example:
      // await generatePlantSprite(event.plant); // <-- make HTTP call to Java service
      add(LoadPlant(event.updatedPlant.plantId));
    } catch (e) {
      emit(PlantError(message: e.toString()));
    }
  }

  Future<void> _onWaterPlant(WaterPlant event, Emitter<PlantState> emit) async {
    final currentState = state;
    if (currentState is PlantLoaded) {
      final now = Timestamp.now();
      final updatedPlant = currentState.plant.copyWith(
        hp: (currentState.plant.hp + 10).clamp(0, 100),
        lastCare: {...currentState.plant.lastCare, 'watered': now},
      );
      add(UpdatePlant(updatedPlant));
    }
  }

  Future<void> _onGiveSunlight(
      GiveSunlight event, Emitter<PlantState> emit) async {
    final currentState = state;
    if (currentState is PlantLoaded) {
      final now = Timestamp.now();
      final updatedPlant = currentState.plant.copyWith(
        hp: (currentState.plant.hp + 5).clamp(0, 100),
        lastCare: {...currentState.plant.lastCare, 'sunlight': now},
      );
      add(UpdatePlant(updatedPlant));
    }
  }
}
