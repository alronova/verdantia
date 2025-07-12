import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verdantia/core/services/firebase_service.dart';
import 'package:verdantia/features/settings/bloc/user_cubit.dart';

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
      context.read<UserCubit>().loadUser();
      checkAndNavigateAfterLogin(context);

      return null;
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

      await initializeGardenIfNeeded(username: username, email: email);

      if (!context.mounted) return null;
      context.read<UserCubit>().loadUser();
      checkAndNavigateAfterLogin(context);

      return null;
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

  /// Initializes the Firestore user document if it doesn't exist
  Future<void> initializeGardenIfNeeded({
    String? username,
    String? email,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
    final plotDoc = FirebaseFirestore.instance.collection('plots').doc(uid);

    final userSnap = await userDoc.get();
    final plotSnap = await plotDoc.get();

    // Create user profile if missing
    if (!userSnap.exists) {
      await userDoc.set({
        'email': email ?? '',
        'username': username ?? '',
        'xp': 0,
        'level': 0,
        'coins': 0,
        'onboardingComplete': false,
      });
    }

    // Create default 16 plots if not already there
    if (!plotSnap.exists) {
      final defaultPlots = List.generate(16, (i) {
        return {
          'index': i,
          'unlocked': (i == 0) || (i == 1),
          'plantId': '',
          'lastWater': Timestamp.now(),
          'lastSunlight': Timestamp.now(),
          'lastFertilizer': Timestamp.now(),
        };
      });

      await plotDoc.set({
        'plots': defaultPlots,
      });
    }
  }
}
