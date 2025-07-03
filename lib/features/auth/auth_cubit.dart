import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verdantia/core/services/firebase_service.dart';

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

  Future<String?> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return "Email and password cannot be empty";
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await initializeGardenIfNeeded();

      if (!context.mounted) return null;
      checkAndNavigateAfterLogin(context);

      return null; // success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for this email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for this user.';
      } else {
        return "An unknown error occurred";
      }
    }
  }

  Future<String?> signup({
    required String email,
    required String password,
    required String username,
    required BuildContext context,
  }) async {
    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      return "Username, email and password cannot be empty";
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await initializeGardenIfNeeded();

      if (!context.mounted) return null;
      checkAndNavigateAfterLogin(context);

      return null; // success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'An account already exists with this email.';
      } else {
        return "An unknown error occurred";
      }
    }
  }

  Future<void> initializeGardenIfNeeded() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = FirebaseFirestore.instance.collection('userdb').doc(uid);
    final doc = await userDoc.get();

    final hasPlots =
        doc.data()?['plot'] != null && (doc.data()?['plot'] as List).isNotEmpty;

    if (!hasPlots) {
      final defaultPlots = List.generate(16, (i) {
        return {
          'index': i,
          'unlocked': i == 0, // Only first one unlocked
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
