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

  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final CollectionReference plotCollection =
      FirebaseFirestore.instance.collection('plots');

  Future<void> _onLoadGarden(
      LoadGarden event, Emitter<GardenState> emit) async {
    emit(GardenLoading());

    try {
      final doc = await plotCollection.doc(userId).get();
      final data = doc.data() as Map<String, dynamic>?;

      if (data == null || data['plots'] == null) {
        throw Exception("No plots found for user.");
      }

      final plots = (data['plots'] as List<dynamic>)
          .map((e) => Plot.fromJson(e))
          .toList();

      emit(GardenLoaded(plots: plots));
    } catch (e) {
      emit(GardenError(message: e.toString()));
    }
  }

  Future<void> _onUpdatePlot(
      UpdatePlot event, Emitter<GardenState> emit) async {
    try {
      final doc = await plotCollection.doc(userId).get();
      final data = doc.data() as Map<String, dynamic>?;

      List<dynamic> plotList = List.from(data?['plots'] ?? []);
      bool updated = false;

      for (int i = 0; i < plotList.length; i++) {
        if (plotList[i]['index'] == event.plot.index) {
          plotList[i] = event.plot.toJson();
          updated = true;
          break;
        }
      }

      if (!updated) {
        plotList.add(event.plot.toJson());
      }

      await plotCollection.doc(userId).update({'plots': plotList});
      add(LoadGarden());
    } catch (e) {
      emit(GardenError(message: e.toString()));
    }
  }

  Future<void> _onUnlockPlot(
      UnlockPlot event, Emitter<GardenState> emit) async {
    final currentState = state;
    if (currentState is GardenLoaded) {
      final plot = currentState.plots.firstWhere(
        (p) => p.index == event.index,
        orElse: () => Plot(index: event.index, unlocked: false),
      );

      final updatedPlot = plot.copyWith(unlocked: true);
      add(UpdatePlot(updatedPlot));
    }
  }
}
