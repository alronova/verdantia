part of './plot_bloc.dart';

class PlotState extends Equatable {
  final Plot plot;
  final bool isWatered;

  const PlotState({required this.plot, this.isWatered = false});

  PlotState copyWith({Plot? plot, bool? isWatered}) => PlotState(
        plot: plot ?? this.plot,
        isWatered: isWatered ?? this.isWatered,
      );

  @override
  List<Object?> get props => [plot, isWatered];
}
