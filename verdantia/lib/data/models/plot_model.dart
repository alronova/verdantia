class Plot {
  final int index;
  final bool unlocked;
  final String? plantId;

  Plot({
    required this.index,
    required this.unlocked,
    this.plantId,
  });

  factory Plot.fromJson(Map<String, dynamic> json) => Plot(
        index: json['index'],
        unlocked: json['unlocked'],
        plantId: json['plantid'],
      );

  Map<String, dynamic> toJson() => {
        'index': index,
        'unlocked': unlocked,
        'plantid': plantId,
      };

  Plot copyWith({int? index, bool? unlocked, String? plantId}) => Plot(
        index: index ?? this.index,
        unlocked: unlocked ?? this.unlocked,
        plantId: plantId ?? this.plantId,
      );
}
