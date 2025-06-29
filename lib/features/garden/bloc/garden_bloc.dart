import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// models
import '../../../data/models/plot_model.dart';

part './garden_event.dart';
part './garden_state.dart';

class GardenBloc extends Bloc<GardenEvent, GardenState> {
  GardenBloc() : super(GardenInitial()) {
    on<LoadGarden>(_onLoadGarden);
    on<UpdatePlot>(_onUpdatePlot);
    on<UnlockPlot>(_onUnlockPlot);
  }

  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final userDoc = FirebaseFirestore.instance.collection('userdb');

  Future<void> _onLoadGarden(
      LoadGarden event, Emitter<GardenState> emit) async {
    emit(GardenLoading());

    try {
      final doc = await userDoc.doc(userId).get();
      final data = doc.data();
      if (data == null) throw Exception("User not found");

      final plots =
          (data['plot'] as List<dynamic>).map((e) => Plot.fromJson(e)).toList();
      emit(GardenLoaded(plots: plots));
    } catch (e) {
      emit(GardenError(message: e.toString()));
    }
  }

  Future<void> _onUpdatePlot(
      UpdatePlot event, Emitter<GardenState> emit) async {
    try {
      final doc = await userDoc.doc(userId).get();
      final data = doc.data();
      if (data == null) throw Exception("User not found");

      List<dynamic> plotList = List.from(data['plot'] ?? []);
      bool updated = false;

      for (int i = 0; i < plotList.length; i++) {
        if (plotList[i]['index'] == event.plot.index) {
          plotList[i] = event.plot.toJson();
          updated = true;
          break;
        }

        if (!updated) {
          plotList.add(event.plot.toJson());
        }

        await userDoc.doc(userId).update({'plot': plotList});
        add(LoadGarden());
      }
    } catch (e) {
      emit(GardenError(message: e.toString()));
    }
  }

  Future<void> _onUnlockPlot(
      UnlockPlot event, Emitter<GardenState> emit) async {
    final currentState = state;
    if (currentState is GardenLoaded) {
      final plot = currentState.plots.firstWhere((p) => p.index == event.index,
          orElse: () => Plot(index: event.index, unlocked: false));
      final updatedPlot =
          Plot(index: plot.index, unlocked: true, plantId: plot.plantId);
      add(UpdatePlot(updatedPlot));
    }
  }
}
