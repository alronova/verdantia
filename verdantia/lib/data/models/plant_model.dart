// import 'dart:ffi';

class Plant {
  final String plantId;
  final String uid;
  final String type;
  final Map<String, String> appearance;
  final int hp;
  final int growthStage;
  final Map<String, String> lastCare;

  const Plant({
    required this.plantId,
    required this.uid,
    required this.type,
    required this.appearance,
    required this.hp,
    required this.growthStage,
    required this.lastCare,
  });
}
