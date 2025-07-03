class WeatherData {
  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;
  final double windSpeed;
  final int humidity;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.windSpeed,
    required this.humidity,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'],
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'],
      iconCode: json['weather'][0]['icon'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      humidity: json['main']['humidity'],
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@4x.png';
}
