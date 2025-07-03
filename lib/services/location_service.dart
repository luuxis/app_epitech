import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Le service de localisation est désactivé.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('La permission de localisation est refusée.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'La permission de localisation est refusée de manière permanente. Veuillez l\'activer dans les paramètres.',
      );
    }

    final LocationSettings locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
    );

    return await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
  }
}
