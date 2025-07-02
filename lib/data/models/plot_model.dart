import 'package:cloud_firestore/cloud_firestore.dart';

class Plot {
  final int index;
  final bool unlocked;
  final String? plantId;
  final DateTime? lastWatered;

  Plot({
    required this.index,
    required this.unlocked,
    this.plantId,
    this.lastWatered,
  });

  factory Plot.fromJson(Map<String, dynamic> json) => Plot(
        index: json['index'],
        unlocked: json['unlocked'],
        plantId: json['plantid'],
        lastWatered: json['lastwatered'] != null
            ? (json['lastwatered'] as Timestamp).toDate()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'index': index,
        'unlocked': unlocked,
        'plantid': plantId,
        'lastwatered':
            lastWatered != null ? Timestamp.fromDate(lastWatered!) : null,
      };

  Plot copyWith({
    int? index,
    bool? unlocked,
    String? plantId,
    DateTime? lastWatered,
  }) =>
      Plot(
        index: index ?? this.index,
        unlocked: unlocked ?? this.unlocked,
        plantId: plantId ?? this.plantId,
        lastWatered: lastWatered ?? this.lastWatered,
      );

  // bool get isWatered {
  //   if (lastWatered == null) return false;
  //   final now = DateTime.now();
  //   return now.difference(lastWatered!).inHours < 12;
  // }
}

// keep emitting PlotLoaded state with updated lastWatered
