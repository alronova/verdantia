import 'package:flutter_bloc/flutter_bloc.dart';

class SelectedPlantsCubit extends Cubit<List<String>> {
  SelectedPlantsCubit() : super([]);

  void selectPlants(List<String> plants) {
    emit(plants);
  }

  void clearSelection() {
    emit([]);
  }

  void addPlants(List<String> newPlants) {
    final updated = {...state, ...newPlants}.toList();
    emit(updated);
  }
}
