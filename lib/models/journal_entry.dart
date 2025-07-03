import 'weather_data.dart';

class JournalEntry {
  final String imagePath;
  final WeatherData weatherData;
  final String motionStatus;
  final DateTime timestamp;

  JournalEntry({
    required this.imagePath,
    required this.weatherData,
    required this.motionStatus,
    required this.timestamp,
  });
}
