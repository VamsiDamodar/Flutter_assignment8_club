import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vamsi_assignment/models/experience.dart';

class ApiService {
  static const String baseUrl = 'https://staging.chamberofsecrets.8club.co';

  static Future<List<Experience>> fetchExperiences() async {
    final response = await http.get(Uri.parse('$baseUrl/v1/experiences?active=true'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data']['experiences'] as List;
      return data.map((e) => Experience.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load experiences');
    }
  }
}