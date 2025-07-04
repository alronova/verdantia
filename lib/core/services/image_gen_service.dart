import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

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
