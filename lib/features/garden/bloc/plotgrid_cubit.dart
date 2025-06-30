import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/plot_model.dart';

class PlotsCubit extends Cubit<List<Plot>> {
  PlotsCubit() : super([]);

  final Map<int, int> animatedFrame = {}; // index -> current frame
  Timer? _animationTimer;

  void setPlots(List<Plot> plots) => emit(plots);

  void waterPlot(int index) {
    final updated = state.map((plot) {
      if (plot.index == index) {
        return plot.copyWith(lastWatered: DateTime.now());
      }
      return plot;
    }).toList();

    emit(updated);

    // Start watering animation for this plot
    _animateWatering(index);
  }

  void _animateWatering(int index) {
    animatedFrame[index] = 0;

    _animationTimer?.cancel(); // Stop previous animation if any
    _animationTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      final current = animatedFrame[index] ?? 0;
      if (current >= 18) {
        timer.cancel();
        animatedFrame.remove(index);
      } else {
        animatedFrame[index] = current + 1;
        emit(List.from(state)); // Trigger repaint
      }
    });
  }

  Plot getByIndex(int index) => state.firstWhere((p) => p.index == index);

  int? getAnimationFrame(int index) => animatedFrame[index];
}
