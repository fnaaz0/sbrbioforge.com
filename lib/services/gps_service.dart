import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'environment_model.dart';

/// Service for GPS location detection with offline fallback
class GpsService {
  static final GpsService _instance = GpsService._internal();

  factory GpsService() {
    return _instance;
  }

  GpsService._internal();

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      if (kDebugMode) {
        print('Error checking location service: $e');
      }
      return false;
    }
  }

  /// Request location permissions
  Future<LocationPermission> requestLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        return await Geolocator.requestPermission();
      } else if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, open app settings
        await Geolocator.openLocationSettings();
        return LocationPermission.deniedForever;
      }
      
      return permission;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting location permission: $e');
      }
      return LocationPermission.deniedForever;
    }
  }

  /// Get current GPS location with fallback
  Future<GpsLocation?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) {
          print('Location services are disabled. Using offline fallback.');
        }
        return _getOfflineFallbackLocation();
      }

      // Check and request permissions
      final permission = await requestLocationPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (kDebugMode) {
          print('Location permission denied. Using offline fallback.');
        }
        return _getOfflineFallbackLocation();
      }

      // Get current position with timeout
      final position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 10),
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () async {
          if (kDebugMode) {
            print('GPS timeout. Attempting low-accuracy fallback.');
          }
          return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
          );
        },
      );

      return GpsLocation.fromPosition(position);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current location: $e. Using offline fallback.');
      }
      return _getOfflineFallbackLocation();
    }
  }

  /// Watch location changes (streaming)
  Stream<GpsLocation> watchLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // meters
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    ).map((position) => GpsLocation.fromPosition(position)).handleError((error) {
      if (kDebugMode) {
        print('Location stream error: $error');
      }
    });
  }

  /// Offline fallback: Delhi, India (default safe zone)
  GpsLocation _getOfflineFallbackLocation() {
    return GpsLocation(
      latitude: 28.6139,
      longitude: 77.2090,
      accuracy: 10000, // High uncertainty
      altitude: 216,
      timestamp: DateTime.now(),
    );
  }

  /// Get location name from coordinates using reverse geocoding
  Future<String> getLocationName(double latitude, double longitude) async {
    try {
      final placemarks = await GeolocatorPlatform.instance
          .placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.locality ?? place.administrativeArea ?? "Unknown"}, ${place.country ?? ""}';
      }
      return 'Unknown Location';
    } catch (e) {
      if (kDebugMode) {
        print('Error getting location name: $e');
      }
      return 'Location Unavailable';
    }
  }

  /// Calculate distance between two coordinates (Haversine formula)
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const int earthRadius = 6371; // km
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    
    final a = (Math.sin(dLat / 2) * Math.sin(dLat / 2)) +
        (Math.cos(_toRad(lat1)) * Math.cos(_toRad(lat2)) * 
         Math.sin(dLon / 2) * Math.sin(dLon / 2));
    
    final c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRad(double degree) => degree * (3.141592653589793 / 180);
}

/// Math helper class
class Math {
  static double sin(double radians) => throw UnimplementedError();
  static double cos(double radians) => throw UnimplementedError();
  static double atan2(double y, double x) => throw UnimplementedError();
  static double sqrt(double value) => throw UnimplementedError();
}
