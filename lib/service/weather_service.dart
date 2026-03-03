import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Using Open-Meteo (No API Key required for development)
  static const String _baseUrl = "https://api.open-meteo.com/v1/forecast";

  Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    final url = Uri.parse("$_baseUrl?latitude=$lat&longitude=$lon&current_weather=true");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print("response ${response.statusCode}");
        print("response ${response.body}");
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load weather");
      }
    } catch (e) {
      throw Exception("Error fetching weather: $e");
    }
  }
}