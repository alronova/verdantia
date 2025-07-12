import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/plant_model.dart';

Future<String> generatePlantSprite(String prompt) async {
  // Extract base name, e.g., "oak" from "oak age-80 smth"

  final dir = await getApplicationDocumentsDirectory();
  final path = '${dir.path}/plants/$prompt.png';
  final file = File(path);

  if (await file.exists()) {
    return path; // Return cached image path
  }

  final dio = Dio();
  try {
    final response = await dio.post<List<int>>(
      'https://verdara.onrender.com/api/prompt',
      data: prompt,
      options: Options(
        headers: {
          HttpHeaders.contentTypeHeader: 'text/plain',
        },
        responseType: ResponseType.bytes,
      ),
    );

    await file.create(recursive: true);
    await file.writeAsBytes(response.data!);

    return path;
  } catch (e) {
    throw Exception('Failed to generate plant: $e');
  }
}

Future<String> generatePlantSpriteFromPlant(Plant plant) async {
  final prompt = _formatPrompt(plant);
  print("🪴 Sprite Prompt: $prompt"); // Add this log

  final dir = await getApplicationDocumentsDirectory();
  final path = '${dir.path}/plants/$prompt.png';
  final file = File(path);

  if (await file.exists()) {
    print("📂 Cached sprite found: $path");
    return path;
  }

  final dio = Dio();
  try {
    final response = await dio.post<List<int>>(
      'https://verdara.onrender.com/api/prompt',
      data: prompt,
      options: Options(
        headers: {
          HttpHeaders.contentTypeHeader: 'text/plain',
        },
        responseType: ResponseType.bytes,
      ),
    );

    await file.create(recursive: true);
    await file.writeAsBytes(response.data!);

    print("✅ Sprite generated and saved: $path");
    return path;
  } catch (e) {
    print("❌ Failed to generate sprite: $e");
    throw Exception('Failed to generate plant sprite: $e');
  }
}

String _formatPrompt(Plant plant) {
  final name = plant.plantName.toLowerCase();
  final age = plant.age;

  final hasDisease = plant.diseaseIntensity != 0;
  final diseasePrompt =
      hasDisease ? "${plant.disease}-${plant.diseaseIntensity}" : "";

  return "$name age-$age $diseasePrompt";
}
