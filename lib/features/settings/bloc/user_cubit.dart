import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verdantia/data/models/user_model.dart';

class UserCubit extends Cubit<AppUser?> {
  final FirebaseFirestore firestore;
  final String uid;

  UserCubit(this.firestore, this.uid) : super(null);

  /// Load user
  Future<void> loadUser() async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      emit(AppUser.fromJson(doc.data()!));
    }
  }

  /// Update coins
  Future<void> updateCoins(int coins) async {
    await firestore.collection('users').doc(uid).update({'coins': coins});
    emit(state?.copyWith(coins: coins));
  }

  /// Update XP
  /// Update XP and handle level up if needed
  Future<void> updateXp(int xpGain) async {
    int currentXp = state?.xp ?? 0;
    int currentLevel = state?.level ?? 1;
    int newXp = currentXp + xpGain;
    int newLevel = currentLevel;

    // Keep leveling up while XP exceeds required XP for next level
    while (newXp >= xpForLevel(newLevel + 1)) {
      newLevel++;
    }

    await firestore.collection('users').doc(uid).update({
      'xp': newXp,
      'level': newLevel,
    });

    emit(state?.copyWith(xp: newXp, level: newLevel));
  }

  /// XP required to reach a specific level
  int xpForLevel(int level) => level * level * 100;

  /// General handler: e.g. when user submits an action like water/fertilize
  // Future<void> handleActionSubmit({int xpGain = 10, int coinGain = 5}) async {
  //   await updateXp(xpGain); // auto-handles level up
  //   await updateCoins((state?.coins ?? 0) + coinGain);
  // }
}
