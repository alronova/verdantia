import 'package:dio/dio.dart';

final Map<String, String> plantNameToId = {
  'oak': '6867df09a558f2f7341af278',
  'maple': '6867e02ba558f2f7341af27a',
  'willow': '6867e20ea558f2f7341af27c',
  'lady palm': '6867e275a558f2f7341af27e',
  'birch': '6867e287a558f2f7341af280',
  'pine': '6867e298a558f2f7341af282',
};

Future<Map<String, dynamic>> fetchPlantByName(String name) async {
  final id = plantNameToId[name.toLowerCase().trim()];
  if (id == null) {
    throw Exception("No plant ID found for name: $name");
  }

  final url = 'https://fake-servers.onrender.com/plants/$id';
  final response = await Dio().get(url);

  return response.data; // JSON map of plant
}
