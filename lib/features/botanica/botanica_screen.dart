import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/services/plant_service.dart';
import '../garden/widgets/misc_widgets.dart';

const Map<String, String> plantNameToId = {
  'oak': '6867df09a558f2f7341af278',
  'maple': '6867e02ba558f2f7341af27a',
  'willow': '6867e20ea558f2f7341af27c',
  'lady palm': '6867e275a558f2f7341af27e',
  'birch': '6867e287a558f2f7341af280',
  'pine': '6867e298a558f2f7341af282',
};

class BotanicaScreen extends StatefulWidget {
  const BotanicaScreen({super.key});

  @override
  State<BotanicaScreen> createState() => _BotanicaScreenState();
}

class _BotanicaScreenState extends State<BotanicaScreen> {
  late Future<(List<Map<String, dynamic>>, Set<String>)> _combinedFuture;
  // late Future<List<Map<String, dynamic>>> _plantDetailsFuture;
  // final PlantService _plantService = PlantService();
  // late Future<List<Plant>> _userPlantsFuture;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    _combinedFuture = _fetchData(userId);
  }

  Future<(List<Map<String, dynamic>>, Set<String>)> _fetchData(
      String userId) async {
    final metadata = await _fetchAllPlantDetails();
    final userPlants = await PlantService().fetchUserPlants(userId);

    final ownedPlantIds =
        userPlants.map((p) => p.plantName.toLowerCase()).toSet();

    return (metadata, ownedPlantIds);
  }

  Future<Map<String, dynamic>> _fetchPlantDetails(String id) async {
    final response =
        await Dio().get('https://fake-servers.onrender.com/plants/$id');
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> _fetchAllPlantDetails() async {
    final futures = plantNameToId.values.map(_fetchPlantDetails);
    return await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Botanica', style: pixelStyle.copyWith(fontSize: 24)),
        centerTitle: true,
      ),
      body: FutureBuilder<(List<Map<String, dynamic>>, Set<String>)>(
        future: _combinedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final (allPlants, ownedPlants) = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allPlants.length,
            itemBuilder: (context, index) {
              final data = allPlants[index];
              final name = data['plant_name'].toString().toLowerCase();
              final isOwned = ownedPlants.contains(name);

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade700),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name[0].toUpperCase() + name.substring(1),
                            style: pixelStyle.copyWith(fontSize: 20),
                          ),
                        ),
                        Icon(isOwned ? Icons.lock_open : Icons.lock, size: 20),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data['description'] ?? 'No description available.',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
