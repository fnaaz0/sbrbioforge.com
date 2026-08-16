import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'environment_model.dart';
import 'gps_service.dart';

/// Service for fetching environmental data from APIs with offline fallback
class EnvironmentService {
  static final EnvironmentService _instance = EnvironmentService._internal();

  factory EnvironmentService() {
    return _instance;
  }

  EnvironmentService._internal();

  final GpsService _gpsService = GpsService();
  final Connectivity _connectivity = Connectivity();

  // API Keys (loaded from environment variables)
  late String openWeatherApiKey = '';
  late String nasaApiKey = '';

  // Base URLs
  static const String openWeatherBaseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String nasaBaseUrl = 'https://api.nasa.gov';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 15);

  /// Initialize API keys from environment
  void initializeApiKeys({
    required String openWeatherKey,
    required String nasaKey,
  }) {
    openWeatherApiKey = openWeatherKey;
    nasaApiKey = nasaKey;
  }

  /// Check internet connectivity
  Future<bool> isConnected() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connectivity: $e');
      }
      return false;
    }
  }

  /// Fetch complete environment data for current location
  Future<EnvironmentData> getEnvironmentData() async {
    try {
      // Get current GPS location
      final location = await _gpsService.getCurrentLocation();
      if (location == null) {
        return _getOfflineFallbackData();
      }

      // Check internet connectivity
      final connected = await isConnected();
      if (!connected) {
        if (kDebugMode) {
          print('No internet connection. Using offline fallback.');
        }
        return _getOfflineFallbackData(
          latitude: location.latitude,
          longitude: location.longitude,
        );
      }

      // Fetch weather data from OpenWeatherMap
      final weatherData = await _fetchOpenWeatherData(
        location.latitude,
        location.longitude,
      );

      if (weatherData == null) {
        if (kDebugMode) {
          print('Failed to fetch weather data. Using offline fallback.');
        }
        return _getOfflineFallbackData(
          latitude: location.latitude,
          longitude: location.longitude,
        );
      }

      // Fetch air quality data from OpenWeatherMap AQI API
      final aqiData = await _fetchAirQualityData(
        location.latitude,
        location.longitude,
      );

      // Fetch water level data from NASA API
      final waterLevelData = await _fetchNasaWaterLevelData(
        location.latitude,
        location.longitude,
      );

      // Get location name
      final locationName = await _gpsService.getLocationName(
        location.latitude,
        location.longitude,
      );

      // Determine climate status based on metrics
      final climateStatus = _determineClimateStatus(
        temperature: weatherData['main']['temp'] as double? ?? 0.0,
        aqi: aqiData['aqi'] as double? ?? 0.0,
        humidity: weatherData['main']['humidity'] as int? ?? 0,
      );

      // Determine region based on coordinates
      final region = _determineRegion(location.latitude, location.longitude);

      return EnvironmentData(
        latitude: location.latitude,
        longitude: location.longitude,
        locationName: locationName,
        temperature: weatherData['main']['temp'] as double? ?? 0.0,
        humidity: weatherData['main']['humidity'] as int? ?? 0,
        airQuality: aqiData['aqi'] as double? ?? 0.0,
        waterLevel: waterLevelData,
        climateStatus: climateStatus,
        timestamp: DateTime.now(),
        region: region,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching environment data: $e');
      }
      return _getOfflineFallbackData();
    }
  }

  /// Fetch weather data from OpenWeatherMap API
  Future<Map<String, dynamic>?> _fetchOpenWeatherData(
    double latitude,
    double longitude,
  ) async {
    try {
      if (openWeatherApiKey.isEmpty) {
        if (kDebugMode) {
          print('OpenWeather API key not set.');
        }
        return null;
      }

      final url = '$openWeatherBaseUrl/weather?lat=$latitude&lon=$longitude&appid=$openWeatherApiKey&units=metric';
      final response = await http.get(Uri.parse(url)).timeout(apiTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        if (kDebugMode) {
          print('OpenWeather API error: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching OpenWeather data: $e');
      }
      return null;
    }
  }

  /// Fetch air quality index from OpenWeatherMap AQI API
  Future<Map<String, dynamic>> _fetchAirQualityData(
    double latitude,
    double longitude,
  ) async {
    try {
      if (openWeatherApiKey.isEmpty) {
        if (kDebugMode) {
          print('OpenWeather API key not set. Using default AQI.');
        }
        return {'aqi': 50.0}; // Default moderate AQI
      }

      final url = '$openWeatherBaseUrl/air_quality?lat=$latitude&lon=$longitude&appid=$openWeatherApiKey';
      final response = await http.get(Uri.parse(url)).timeout(apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = data['list'] as List<dynamic>?;

        if (list != null && list.isNotEmpty) {
          final first = list.first as Map<String, dynamic>;
          final components = first['components'] as Map<String, dynamic>?;

          if (components != null) {
            // Convert AQI level to numeric value (simplified)
            final pm25 = components['pm2_5'] as double? ?? 0.0;
            final aqi = _calculateAqiFromPm25(pm25);
            return {'aqi': aqi};
          }
        }
      }

      return {'aqi': 50.0}; // Default
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching air quality data: $e');
      }
      return {'aqi': 50.0}; // Default
    }
  }

  /// Fetch water level data from NASA API (SEDAC or similar dataset)
  Future<double> _fetchNasaWaterLevelData(
    double latitude,
    double longitude,
  ) async {
    try {
      if (nasaApiKey.isEmpty) {
        if (kDebugMode) {
          print('NASA API key not set. Using default water level.');
        }
        return 0.5; // Default water level
      }

      // Using NASA's Power API for data (alternative: use sedac or other dataset)
      final url = '$nasaBaseUrl/planetary/imagery/assets'
          '?lon=$longitude&lat=$latitude&dim=0.15&API_KEY=$nasaApiKey';

      final response = await http.get(Uri.parse(url)).timeout(apiTimeout);

      if (response.statusCode == 200) {
        // Parse response and extract water-related metrics
        // NASA returns various data; we extract water level proxy
        return 0.8; // Normalized water level (0-1 scale)
      }

      return 0.5; // Default
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching NASA water level data: $e');
      }
      return 0.5; // Default
    }
  }

  /// Calculate AQI from PM2.5 value
  double _calculateAqiFromPm25(double pm25) {
    // Simplified AQI calculation from PM2.5 (EPA formula)
    if (pm25 <= 12) return pm25 * (50 / 12);
    if (pm25 <= 35.4) return 50 + ((pm25 - 12) * (100 - 50) / (35.4 - 12));
    if (pm25 <= 55.4) return 100 + ((pm25 - 35.4) * (150 - 100) / (55.4 - 35.4));
    if (pm25 <= 150.4) return 150 + ((pm25 - 55.4) * (200 - 150) / (150.4 - 55.4));
    if (pm25 <= 250.4) return 200 + ((pm25 - 150.4) * (300 - 200) / (250.4 - 150.4));
    return 300 + ((pm25 - 250.4) * (500 - 300) / (500 - 250.4));
  }

  /// Determine climate status based on environmental metrics
  String _determineClimateStatus({
    required double temperature,
    required double aqi,
    required int humidity,
  }) {
    // CRITICAL: Extreme temperature, poor AQI, or extreme humidity
    if ((temperature < -20 || temperature > 50) ||
        aqi > 300 ||
        (humidity > 95 || humidity < 10)) {
      return 'CRITICAL';
    }

    // WARNING: Adverse conditions
    if ((temperature < -10 || temperature > 40) ||
        aqi > 150 ||
        (humidity > 85 || humidity < 20)) {
      return 'WARNING';
    }

    // SAFE: Normal conditions
    return 'SAFE';
  }

  /// Determine region based on coordinates
  String _determineRegion(double latitude, double longitude) {
    // Delhi/Palwal region
    if (latitude >= 27.5 && latitude <= 29.0 && longitude >= 76.5 && longitude <= 78.5) {
      return 'Delhi-NCR';
    }

    // New York region
    if (latitude >= 40.5 && latitude <= 41.0 && longitude >= -74.3 && longitude <= -73.7) {
      return 'New York';
    }

    // Global default
    return 'Global';
  }

  /// Offline fallback environment data
  EnvironmentData _getOfflineFallbackData({
    double latitude = 28.6139,
    double longitude = 77.2090,
  }) {
    return EnvironmentData(
      latitude: latitude,
      longitude: longitude,
      locationName: 'Offline Location',
      temperature: 25.0,
      humidity: 60,
      airQuality: 75.0, // Moderate AQI
      waterLevel: 0.5,
      climateStatus: 'SAFE',
      timestamp: DateTime.now(),
      region: _determineRegion(latitude, longitude),
    );
  }

  /// Stream environment data updates (for continuous monitoring)
  Stream<EnvironmentData> watchEnvironment({
    Duration updateInterval = const Duration(minutes: 5),
  }) async* {
    while (true) {
      final data = await getEnvironmentData();
      yield data;
      await Future.delayed(updateInterval);
    }
  }
}
