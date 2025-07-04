import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verdantia/data/models/user_model.dart';

class UserCubit extends Cubit<AppUser?> {
  final FirebaseFirestore firestore;
  final String uid;

  UserCubit(this.firestore, this.uid) : super(null);

  /// Load user
  Future<void> loadUser() async {
    final doc = await firestore.collection('userdb').doc(uid).get();
    emit(AppUser.fromJson(doc.data()!));
  }

  /// Update coins
  Future<void> updateCoins(int coins) async {
    await firestore.collection('userdb').doc(uid).update({'coins': coins});
    emit(state?.copyWith(coins: coins));
  }

  /// Update XP
  Future<void> updateXp(int xp) async {
    await firestore.collection('userdb').doc(uid).update({'xp': xp});
    emit(state?.copyWith(xp: xp));
  }

  /// Update level
  Future<void> updateLevel(int level) async {
    await firestore.collection('userdb').doc(uid).update({'level': level});
    emit(state?.copyWith(level: level));
  }

  /// General handler: e.g. when user submits an action like water/fertilize
  Future<void> handleActionSubmit({int xpGain = 10, int coinGain = 5}) async {
    final currentXp = state?.xp ?? 0;
    final currentCoins = state?.coins ?? 0;

    final newXp = currentXp + xpGain;
    final newCoins = currentCoins + coinGain;

    await firestore.collection('userdb').doc(uid).update({
      'xp': newXp,
      'coins': newCoins,
    });

    emit(state?.copyWith(xp: newXp, coins: newCoins));
  }
}
