import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// models
import '../../data/models/plant_model.dart';

// function to create user doc in firestore
Future<Map<String, dynamic>> addUserToFirestore(
    {required String email,
    required String uid,
    required String username}) async {
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final docRef = FirebaseFirestore.instance.collection('userdb').doc(userId);

  try {
    // check if doc already exists
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      return {
        "status": "exists",
        "message": "User already exists in Firestore."
      };
    }

    // create user document
    await docRef.set({
      "email": email,
      "uid": uid,
      "username": username,
      "coins": 50,
      "level": 0,
      "xp": 0,
      "plot": [],
    });

    return {
      "status": "success",
      "message": "User added to Firestore successfully."
    };
  } catch (e) {
    return {
      "status": "error",
      "message": "Failed to add user to Firestore: $e"
    };
  }
}

// function to update plants belonging to a user
Future<Map<String, dynamic>> updatePlants(
    {required Plant plant, required int plotIndex}) async {
  // getting the db
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final docRef = FirebaseFirestore.instance.collection('userdb').doc(userId);

  try {
    final snapshot = await docRef.get();
    final data = snapshot.data();

    if (data == null) throw Exception("User data not found");

    final List<dynamic> plots = List.from(data['plot' ?? []]);

    bool updated = false;

    // modify in place if the plot index exists
    for (int i = 0; i < plots.length; i++) {
      if (plots[i]['index'] == plotIndex) {
        plots[i]['plantid'] == plant.plantId;
        updated = true;
        break;
      }
    }

    // if not found, append a new entry
    if (!updated) {
      plots.add({
        'index': plotIndex,
        'plantid': plant.plantId,
        'unlocked': true,
      });
    }

    // write back to firestore
    await docRef.update({'plot': plots});

    return {
      "status": "success",
      "message": updated ? "Plant updated." : "Plant added successfully."
    };
  } catch (e) {
    return {
      "status": "error",
      "message": "An error occurred while trying to add plant: $e"
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

  final docRef = FirebaseFirestore.instance.collection('userdb').doc(user!.uid);

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
