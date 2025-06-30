import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AuthStatus { authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? username;

  AuthState({required this.status, required this.username});

  factory AuthState.unauthenticated() =>
      AuthState(status: AuthStatus.unauthenticated, username: "Guest");

  factory AuthState.authenticated({required String username}) =>
      AuthState(status: AuthStatus.authenticated, username: username);
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState.unauthenticated());

  void login({required String username}) {
    emit(AuthState.authenticated(username: username));
  }

  void logout() {
    emit(AuthState.unauthenticated());
  }

  Future<void> initializeGardenIfNeeded() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = FirebaseFirestore.instance.collection('userdb').doc(uid);
    final doc = await userDoc.get();

    if (!doc.exists || !(doc.data()?['plot']?.isNotEmpty ?? false)) {
      // Generate 16 default plots
      final List<Map<String, dynamic>> defaultPlots = List.generate(16, (i) {
        return {
          'index': i,
          'unlocked': i == 0, // unlock first one
          'plantid': '',
          'lastWatered': Timestamp.now(),
        };
      });

      await userDoc.set({
        'uid': uid,
        'email': FirebaseAuth.instance.currentUser?.email ?? '',
        'username': '',
        'xp': 0,
        'level': 0,
        'coins': 0,
        'plot': defaultPlots,
      }, SetOptions(merge: true));
    }
  }
}
