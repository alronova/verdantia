import 'package:cloud_firestore/cloud_firestore.dart';

class PlotService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all plots for a given user
  Future<List<Map<String, dynamic>>> getPlots(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      throw Exception("User not found");
    }

    final plots = List<Map<String, dynamic>>.from(doc.data()?['plots'] ?? []);
    return plots;
  }

  /// Update a single plot at a given index
  Future<void> updatePlot({
    required String uid,
    required int index,
    required Map<String, dynamic> newPlotData,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);

    final doc = await userRef.get();
    if (!doc.exists) throw Exception("User not found");

    List<dynamic> plots = List.from(doc.data()?['plots'] ?? []);

    // Ensure plots list has at least `index + 1` items
    while (plots.length <= index) {
      plots.add({
        "index": plots.length,
        "lastWater": null,
        "lastSunlight": null,
        "lastFertilizer": null,
        "plantId": "",
        "unlocked": false,
      });
    }

    // Update the plot at the given index
    plots[index] = {
      ...plots[index],
      ...newPlotData,
      "index": index,
    };

    await userRef.update({
      'plots': plots,
    });
  }

  /// Unlock a plot
  Future<void> unlockPlot(String uid, int index) async {
    await updatePlot(
      uid: uid,
      index: index,
      newPlotData: {'unlocked': true},
    );
  }

  /// Water a plot (update lastWater timestamp)
  Future<void> waterPlot(String uid, int index) async {
    await updatePlot(
      uid: uid,
      index: index,
      newPlotData: {'lastWater': Timestamp.now()},
    );
  }

  /// Fertilize a plot
  Future<void> fertilizePlot(String uid, int index) async {
    await updatePlot(
      uid: uid,
      index: index,
      newPlotData: {'lastFertilizer': Timestamp.now()},
    );
  }

  /// Give sunlight to a plot
  Future<void> sunlightPlot(String uid, int index) async {
    await updatePlot(
      uid: uid,
      index: index,
      newPlotData: {'lastSunlight': Timestamp.now()},
    );
  }

  /// Assign a plant ID to a plot
  Future<void> assignPlantToPlot(String uid, int index, String plantId) async {
    await updatePlot(
      uid: uid,
      index: index,
      newPlotData: {'plantId': plantId},
    );
  }
}
