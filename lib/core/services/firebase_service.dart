import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// models
import '../../data/models/plant_model.dart';

// function to create user doc in firestore
Future<Map<String, dynamic>> addUserToFirestore({
  required String email,
  required String uid,
  required String username,
}) async {
  final docRef = FirebaseFirestore.instance.collection('users').doc(uid);

  try {
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      return {
        "status": "exists",
        "message": "User already exists in Firestore.",
      };
    }

    await docRef.set({
      "email": email,
      "username": username,
      "coins": 0,
      "level": 0,
      "xp": 0,
      "onboardingComplete": false,
    });

    return {
      "status": "success",
      "message": "User added to Firestore successfully.",
    };
  } catch (e) {
    return {
      "status": "error",
      "message": "Failed to add user to Firestore: $e",
    };
  }
}

// function to check if onboarding is complete
Future<void> checkAndNavigateAfterLogin(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    if (!context.mounted) return;
    context.go('/');
  }

  final docRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);

  try {
    final docSnap = await docRef.get();

    if (!docSnap.exists || docSnap.data()?['onboardingComplete'] != true) {
      // if user doc doesnt exist
      if (!context.mounted) return;
      context.go('/onboarding');
    } else {
      if (!context.mounted) return;
      context.go('/garden');
    }
  } catch (e) {
    print('Error checking onboarding: $e');
  }
}
