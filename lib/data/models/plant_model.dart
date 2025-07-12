// import 'package:cloud_firestore/cloud_firestore.dart';

class Plant {
  final String plantName;
  final String plantId;
  final String uid;
  final int hp;
  final int age;
  final String disease;
  final int diseaseIntensity;
  final int plotIndex;

  Plant({
    required this.plantName,
    required this.plantId,
    required this.uid,
    required this.hp,
    required this.age,
    required this.disease,
    required this.diseaseIntensity,
    required this.plotIndex,
  });

  // factory Plant.fromJson(Map<String, dynamic> json) => Plant(
  //       plantName: json['plantName'],
  //       plantId: json['plantId'],
  //       uid: json['uid'],
  //       appearance: json['appearance'],
  //       hp: json['hp'],
  //       age: json['age'],
  //       growthStage: json['growthStage'],
  //       plotIndex: json['plotIndex'],
  //     );

  // Map<String, dynamic> toJson() => {
  //       'plantName': plantName,
  //       'plantId': plantId,
  //       'uid': uid,
  //       'appearance': appearance,
  //       'hp': hp,
  //       'age': age,
  //       'growthStage': growthStage,
  //       'plotIndex': plotIndex,
  //     };

  Plant copyWith({
    int? hp,
    int? age,
    int? growthStage,
    String? disease,
    int? diseaseIntensity,
  }) {
    return Plant(
      plantName: plantName,
      plantId: plantId,
      uid: uid,
      hp: hp ?? this.hp,
      age: age ?? this.age,
      disease: disease ?? this.disease,
      diseaseIntensity: diseaseIntensity ?? this.diseaseIntensity,
      plotIndex: plotIndex,
    );
  }
}
