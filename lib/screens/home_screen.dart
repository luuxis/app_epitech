import 'package:flutter/material.dart';
import '../api/weather_api.dart';
import '../models/weather_data.dart';
import '../services/location_service.dart';
import 'camera_screen.dart';
import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  final WeatherApiService _weatherApiService = WeatherApiService();
  late Future<WeatherData> _weatherDataFuture;

  StreamSubscription? _accelerometerSubscription;
  String _motionStatus = 'Analyse en cours...';

  @override
  void initState() {
    super.initState();
    _weatherDataFuture = _fetchWeatherData();
    _startListeningToSensor();
  }

  void _startListeningToSensor() {
    _accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        double magnitude = sqrt(
          pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2),
        );

        if (magnitude > 10.5 || magnitude < 9.0) {
          if (_motionStatus != 'En Mouvement') {
            setState(() {
              _motionStatus = 'En Mouvement';
            });
          }
        } else {
          if (_motionStatus != 'Immobile') {
            setState(() {
              _motionStatus = 'Immobile';
            });
          }
        }
      },
      onError: (e) {
        setState(() {
          _motionStatus = 'Capteur indisponible';
        });
      },
      cancelOnError: true,
    );
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  Future<WeatherData> _fetchWeatherData() async {
    try {
      final position = await _locationService.getCurrentPosition();
      final weather = await _weatherApiService.getCurrentWeather(
        position.latitude,
        position.longitude,
      );
      return weather;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des données : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma Météo Actuelle'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: FutureBuilder<WeatherData>(
          future: _weatherDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Erreur : ${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              );
            } else if (snapshot.hasData) {
              final weather = snapshot.data!;
              return _buildWeatherUI(weather);
            } else {
              return const Text('Aucune donnée à afficher.');
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CameraScreen()),
          );
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  Widget _buildWeatherUI(WeatherData weather) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            weather.cityName,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Image.network(weather.iconUrl, scale: 0.7),
          const SizedBox(height: 10),
          Text(
            '${weather.temperature.toStringAsFixed(1)}°C',
            style: const TextStyle(fontSize: 50, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 10),
          Text(
            weather.description.toUpperCase(),
            style: const TextStyle(fontSize: 20, letterSpacing: 1.2),
          ),
          const SizedBox(height: 30),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 132, 132, 132),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.directions_walk, size: 20),
                const SizedBox(width: 8),
                Text(
                  'État : $_motionStatus',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoColumn('Vent', '${weather.windSpeed} m/s'),
              _buildInfoColumn('Humidité', '${weather.humidity}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
