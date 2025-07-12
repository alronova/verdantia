import 'package:cloud_firestore/cloud_firestore.dart';

class Plot {
  final int index;
  final bool unlocked;
  final String? plantId;
  final Timestamp? lastWater;
  final Timestamp? lastSunlight;
  final Timestamp? lastFertilizer;

  Plot({
    required this.index,
    required this.unlocked,
    this.plantId,
    this.lastWater,
    this.lastSunlight,
    this.lastFertilizer,
  });

  factory Plot.fromJson(Map<String, dynamic> json) => Plot(
        index: json['index'],
        unlocked: json['unlocked'],
        plantId: json['plantId'],
        lastWater: (json['lastWater'] as Timestamp?),
        lastSunlight: (json['lastSunlight'] as Timestamp?),
        lastFertilizer: (json['lastFertilizer'] as Timestamp?),
      );

  Map<String, dynamic> toJson() => {
        'index': index,
        'unlocked': unlocked,
        'plantId': plantId,
        'lastWater': lastWater,
        'lastSunlight': lastSunlight,
        'lastFertilizer': lastFertilizer,
      };

  Plot copyWith({
    int? index,
    bool? unlocked,
    String? plantId,
    Timestamp? lastWater,
    Timestamp? lastSunlight,
    Timestamp? lastFertilizer,
  }) =>
      Plot(
        index: index ?? this.index,
        unlocked: unlocked ?? this.unlocked,
        plantId: plantId ?? this.plantId,
        lastWater: lastWater ?? this.lastWater,
        lastSunlight: lastSunlight ?? this.lastSunlight,
        lastFertilizer: lastFertilizer ?? this.lastFertilizer,
      );
}
