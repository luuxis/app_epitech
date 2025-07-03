// lib/screens/save_entry_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../api/weather_api.dart';
import '../models/journal_entry.dart';
import '../models/weather_data.dart';
import '../services/journal_service.dart';
import '../services/location_service.dart';

class SaveEntryScreen extends StatefulWidget {
  final String imagePath;

  const SaveEntryScreen({super.key, required this.imagePath});

  @override
  State<SaveEntryScreen> createState() => _SaveEntryScreenState();
}

class _SaveEntryScreenState extends State<SaveEntryScreen> {
  final JournalService _journalService = JournalService();
  final LocationService _locationService = LocationService();
  final WeatherApiService _weatherApiService = WeatherApiService();

  late Future<WeatherData> _weatherDataFuture;
  final String _currentMotionStatus = "Stationnaire";

  @override
  void initState() {
    super.initState();
    _weatherDataFuture = _fetchWeatherData();
  }

  Future<WeatherData> _fetchWeatherData() async {
    final Position position = await _locationService.getCurrentPosition();
    return _weatherApiService.getCurrentWeather(
      position.latitude,
      position.longitude,
    );
  }

  void _saveEntry(WeatherData weatherData) {
    final newEntry = JournalEntry(
      imagePath: widget.imagePath,
      weatherData: weatherData,
      motionStatus: _currentMotionStatus,
      timestamp: DateTime.now(),
    );
    _journalService.addEntry(newEntry);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Entrée sauvegardée !')));

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sauvegarder l\'entrée')),
      body: FutureBuilder<WeatherData>(
        future: _weatherDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            final weather = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.file(File(widget.imagePath)),
                  const SizedBox(height: 20),
                  Text(
                    'Météo actuelle : ${weather.temperature}°C, ${weather.description}',
                  ),
                  Text('Lieu : ${weather.cityName}'),
                  Text('État : $_currentMotionStatus'),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _saveEntry(weather),
                    icon: const Icon(Icons.save),
                    label: const Text('Sauvegarder dans le journal'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Erreur inconnue'));
        },
      ),
    );
  }
}
