import 'package:cloud_firestore/cloud_firestore.dart';

class Plant {
  final String plantId;
  final String uid;
  final String type;
  final String appearance; // sad, happy, ok
  final int hp;
  final int growthStage;
  final Map<String, Timestamp> lastCare;

  Plant({
    required this.plantId,
    required this.uid,
    required this.type,
    this.appearance = "ok",
    required this.hp,
    required this.growthStage,
    required this.lastCare,
  });

  factory Plant.fromJson(Map<String, dynamic> json) => Plant(
        plantId: json['plantId'],
        uid: json['uid'],
        type: json['type'],
        appearance: json['appearance'],
        hp: json['hp'],
        growthStage: json['growthStage'],
        lastCare: Map<String, Timestamp>.from(json['lastCare']),
      );

  Map<String, dynamic> toJson() => {
        'plantId': plantId,
        'uid': uid,
        'type': type,
        'appearance': appearance,
        'hp': hp,
        'growthStage': growthStage,
        'lastCare': lastCare,
      };

  Plant copyWith({
    int? hp,
    int? growthStage,
    String? appearance,
    Map<String, Timestamp>? lastCare,
  }) {
    return Plant(
      plantId: plantId,
      uid: uid,
      type: type,
      appearance: appearance ?? this.appearance,
      hp: hp ?? this.hp,
      growthStage: growthStage ?? this.growthStage,
      lastCare: lastCare ?? this.lastCare,
    );
  }
}
