import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherApiService {
  static const _apiKey = '7f4d0ee592f4ba7ce116fad3353c32c3';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<WeatherData> getCurrentWeather(double lat, double lon) async {
    final url =
        '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=fr';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return WeatherData.fromJson(jsonResponse);
    } else {
      throw Exception(
        'Erreur de chargement des données météo actuelles. Code: ${response.statusCode}',
      );
    }
  }

  Future<List<dynamic>> getForecast(double lat, double lon) async {
    final url =
        '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=fr';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['list'];
    } else {
      throw Exception(
        'Erreur de chargement des prévisions. Code: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> getAirPollution(double lat, double lon) async {
    final url =
        'http://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Erreur de chargement de la qualité de l\'air. Code: ${response.statusCode}',
      );
    }
  }

  Future<String> getCityNameFromCoordinates(double lat, double lon) async {
    final url =
        'http://api.openweathermap.org/geo/1.0/reverse?lat=$lat&lon=$lon&limit=1&appid=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        return data[0]['name'];
      }
      return "Lieu inconnu";
    } else {
      throw Exception(
        'Erreur de géocodage inversé. Code: ${response.statusCode}',
      );
    }
  }

  String getWeatherMapUrl(String layer, int zoom, int x, int y) {
    return 'https://tile.openweathermap.org/map/$layer/$zoom/$x/$y.png?appid=$_apiKey';
  }
}
