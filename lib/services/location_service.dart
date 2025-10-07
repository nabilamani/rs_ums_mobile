// lib/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../features/presensi/domain/models/presensi_model.dart';
import 'dart:math' show cos, sqrt, asin;

class LocationService {
  // Koordinat Rumah Sakit (ganti dengan koordinat sebenarnya)
  static const double hospitalLatitude = -7.571465;
  static const double hospitalLongitude = 110.874745;
  static const double allowedRadiusInMeters = 100.0; // 100 meter radius

  // Check if location permission is granted
  Future<bool> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled. Please enable location.',
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Please enable in settings.',
      );
    }

    return true;
  }

  // Get current location
  Future<Position> getCurrentLocation() async {
    await checkPermission();

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
  }

  // Calculate distance between two points using Haversine formula
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 *
        asin(sqrt(a)) *
        1000; // 2 * R * 1000 (R = 6371 km, result in meters)
  }

  // Check if user is within hospital area
  Future<bool> isWithinHospitalArea() async {
    try {
      final position = await getCurrentLocation();
      final distance = calculateDistance(
        position.latitude,
        position.longitude,
        hospitalLatitude,
        hospitalLongitude,
      );

      return distance <= allowedRadiusInMeters;
    } catch (e) {
      rethrow;
    }
  }

  // Get location data with address
  Future<LocationData> getLocationData() async {
    try {
      final position = await getCurrentLocation();

      // Get address from coordinates
      String address = 'Unknown Location';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          address = [
            place.street,
            place.subLocality,
            place.locality,
            place.subAdministrativeArea,
          ].where((e) => e != null && e.isNotEmpty).join(', ');
        }
      } catch (e) {
        // If geocoding fails, use coordinates as address
        address =
            '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      }

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        address: address,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get distance from hospital
  Future<double> getDistanceFromHospital() async {
    try {
      final position = await getCurrentLocation();
      return calculateDistance(
        position.latitude,
        position.longitude,
        hospitalLatitude,
        hospitalLongitude,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Format distance for display
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} meter';
    } else {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
  }
}
