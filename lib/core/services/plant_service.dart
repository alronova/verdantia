import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:verdantia/data/models/plant_model.dart';

class PlantService {
  final Dio _dio = Dio();

  // Base URLs
  final String staticPlantUrl = 'https://fake-servers.onrender.com';
  final String userPlantUrl = 'https://d32fb3e40598.ngrok-free.app';

  /// Fetch static plant metadata by plant ID (e.g., maple, oak)
  Future<Map<String, dynamic>> fetchPlantMetadata(String plantId) async {
    try {
      final response = await _dio.get('$staticPlantUrl/plants/$plantId');
      return response.data;
    } catch (e) {
      print('Error fetching plant metadata: $e');
      rethrow;
    }
  }

  /// Fetch all plants for a given user ID
  Future<List<Plant>> fetchUserPlants(String userId) async {
    try {
      final response = await _dio.get('$userPlantUrl/plants/$userId');

      final rawList = List<Map<String, dynamic>>.from(response.data);

      final plantList = rawList.map((plantJson) {
        return Plant(
          plantName: plantJson['plant_name'],
          plantId: plantJson['plant_id'],
          uid: plantJson['user_id'],
          hp: plantJson['hp'],
          age: plantJson['age'],
          disease: plantJson['disease'],
          diseaseIntensity: plantJson['disease_intensity'],
          plotIndex: plantJson['plot_index'],
        );
      }).toList();

      return plantList;
    } catch (e) {
      print('Error fetching user plants: $e');
      rethrow;
    }
  }

  /// Create a new user-owned plant
  Future<void> createUserPlant({
    required String userId,
    required String plantId,
    required String plantName,
    required int age,
    required int hp,
    required String? disease,
    required int? diseaseIntensity,
    required int plotIndex,
  }) async {
    try {
      final payload = {
        "hp": hp,
        "age": age,
        "disease": disease ?? "",
        "disease_intensity": diseaseIntensity ?? 0,
        "user_id": userId,
        "plant_id": plantId,
        "plant_name": plantName,
        "plot_index": plotIndex,
      };

      final response = await _dio.post(
        '$userPlantUrl/plants',
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Plant created successfully');
      } else {
        print('Plant creation failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating plant: $e');
      rethrow;
    }
  }

  /// Update a single field (like age)
  Future<void> updatePlantField({
    required String plantId,
    required String field,
    required dynamic value,
  }) async {
    try {
      await _dio.patch(
        '$userPlantUrl/plants/$plantId',
        data: {field: value},
      );
    } catch (e) {
      throw Exception('Failed to update plant field: $e');
    }
  }

  /// Update multiple fields (like disease + intensity)
  Future<void> updatePlantFields({
    required String plantId,
    required Map<String, dynamic> fields,
  }) async {
    try {
      await _dio.patch(
        '$userPlantUrl/plants/$plantId',
        data: fields,
      );
    } catch (e) {
      throw Exception('Failed to update plant fields: $e');
    }
  }
}
