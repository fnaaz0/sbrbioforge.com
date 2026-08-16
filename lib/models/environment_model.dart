import 'package:geolocator/geolocator.dart';

/// Environment data model for climate & survival metrics
class EnvironmentData {
  final double latitude;
  final double longitude;
  final String locationName;
  final double temperature;
  final int humidity;
  final double airQuality; // 0-500 AQI scale
  final double waterLevel; // meters
  final String climateStatus; // SAFE, WARNING, CRITICAL
  final DateTime timestamp;
  final String region; // Delhi, New York, etc.

  EnvironmentData({
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.temperature,
    required this.humidity,
    required this.airQuality,
    required this.waterLevel,
    required this.climateStatus,
    required this.timestamp,
    required this.region,
  });

  /// Factory to create from API response
  factory EnvironmentData.fromJson(Map<String, dynamic> json) {
    return EnvironmentData(
      latitude: json['lat'] as double? ?? 0.0,
      longitude: json['lon'] as double? ?? 0.0,
      locationName: json['location_name'] as String? ?? 'Unknown',
      temperature: json['temp'] as double? ?? 0.0,
      humidity: json['humidity'] as int? ?? 0,
      airQuality: json['aqi'] as double? ?? 0.0,
      waterLevel: json['water_level'] as double? ?? 0.0,
      climateStatus: json['status'] as String? ?? 'UNKNOWN',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      region: json['region'] as String? ?? 'Global',
    );
  }

  Map<String, dynamic> toJson() => {
    'lat': latitude,
    'lon': longitude,
    'location_name': locationName,
    'temp': temperature,
    'humidity': humidity,
    'aqi': airQuality,
    'water_level': waterLevel,
    'status': climateStatus,
    'timestamp': timestamp.toIso8601String(),
    'region': region,
  };
}

/// GPS location data model
class GpsLocation {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final DateTime timestamp;

  GpsLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.altitude,
    required this.timestamp,
  });

  factory GpsLocation.fromPosition(Position position) {
    return GpsLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      timestamp: position.timestamp,
    );
  }
}
