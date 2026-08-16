import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../models/environment_model.dart';
import '../services/environment_service.dart';
import '../services/gps_service.dart';

/// Main environment detection flow screen
class EnvironmentFlowScreen extends StatefulWidget {
  const EnvironmentFlowScreen({Key? key}) : super(key: key);

  @override
  State<EnvironmentFlowScreen> createState() => _EnvironmentFlowScreenState();
}

class _EnvironmentFlowScreenState extends State<EnvironmentFlowScreen> {
  late EnvironmentService _environmentService;
  late GpsService _gpsService;

  @override
  void initState() {
    super.initState();
    _environmentService = EnvironmentService();
    _gpsService = GpsService();
    
    // Initialize API keys from environment
    _environmentService.initializeApiKeys(
      openWeatherKey: const String.fromEnvironment('OPENWEATHER_API_KEY', defaultValue: ''),
      nasaKey: const String.fromEnvironment('NASA_API_KEY', defaultValue: ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0C10),
        elevation: 0,
        title: const Text(
          'Environment Detection',
          style: TextStyle(
            color: Color(0xFFC5C6C7),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC5C6C7)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<EnvironmentData>(
        future: _environmentService.getEnvironmentData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingScreen();
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _buildErrorScreen(snapshot.error.toString());
          }

          final envData = snapshot.data!;
          return _buildEnvironmentDisplay(envData);
        },
      ),
    );
  }

  /// Loading screen with premium animation
  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.discreteCircle(
            size: 80,
            secondRingColor: const Color(0xFFC5C6C7),
            thirdRingColor: const Color(0xFF8D8D8D),
            color: const Color(0xFFF2F4F7),
          ),
          const SizedBox(height: 24),
          const Text(
            'Detecting GPS & Environment...',
            style: TextStyle(
              color: Color(0xFFC5C6C7),
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connecting to NASA & OpenWeather APIs',
            style: TextStyle(
              color: Color(0xFF8D8D8D),
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  /// Error screen
  Widget _buildErrorScreen(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFE74C3C),
            ),
            const SizedBox(height: 16),
            const Text(
              'Detection Failed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Using offline fallback mode',
              style: TextStyle(
                color: const Color(0xFFC5C6C7).withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Detection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC5C6C7),
                foregroundColor: const Color(0xFF0B0C10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Main environment display with all data cards
  Widget _buildEnvironmentDisplay(EnvironmentData envData) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GPS Location Card
            _buildGpsLocationCard(envData),
            const SizedBox(height: 16),

            // Climate Status Card (Large, prominent)
            _buildClimateStatusCard(envData),
            const SizedBox(height: 16),

            // Temperature & Humidity Card
            _buildWeatherMetricsCard(envData),
            const SizedBox(height: 16),

            // Air Quality Card
            _buildAirQualityCard(envData),
            const SizedBox(height: 16),

            // Water Level Card
            _buildWaterLevelCard(envData),
            const SizedBox(height: 16),

            // Audio Alert Button (ElevenLabs)
            _buildAudioAlertButton(envData),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// GPS Location Card with coordinates
  Widget _buildGpsLocationCard(EnvironmentData envData) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C23),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC5C6C7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC5C6C7).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Color(0xFFC5C6C7),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'GPS Location',
                style: TextStyle(
                  color: Color(0xFFC5C6C7),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            envData.locationName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0B0C10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCoordinateRow(
                  'Latitude',
                  envData.latitude.toStringAsFixed(6),
                ),
                const SizedBox(height: 8),
                _buildCoordinateRow(
                  'Longitude',
                  envData.longitude.toStringAsFixed(6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Region: ${envData.region} | Updated: ${envData.timestamp.hour}:${envData.timestamp.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: const Color(0xFFC5C6C7).withOpacity(0.6),
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper for coordinate display
  Widget _buildCoordinateRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFFC5C6C7).withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFF2F4F7),
            fontSize: 12,
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Climate Status Card (prominent, large)
  Widget _buildClimateStatusCard(EnvironmentData envData) {
    final statusColor = _getStatusColor(envData.climateStatus);
    final statusIcon = _getStatusIcon(envData.climateStatus);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1C23),
            const Color(0xFF252A35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Climate Status',
                    style: TextStyle(
                      color: const Color(0xFFC5C6C7).withOpacity(0.8),
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    envData.climateStatus,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withOpacity(0.1),
                  border: Border.all(color: statusColor, width: 2),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 40,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getStatusDescription(envData.climateStatus),
            style: TextStyle(
              color: const Color(0xFFC5C6C7).withOpacity(0.7),
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// Weather Metrics Card (Temperature & Humidity)
  Widget _buildWeatherMetricsCard(EnvironmentData envData) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C23),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC5C6C7),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weather Metrics',
            style: TextStyle(
              color: Color(0xFFC5C6C7),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricBox(
                  icon: Icons.thermostat,
                  label: 'Temperature',
                  value: '${envData.temperature.toStringAsFixed(1)}°C',
                  backgroundColor: const Color(0xFF0B0C10),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricBox(
                  icon: Icons.water_drop,
                  label: 'Humidity',
                  value: '${envData.humidity}%',
                  backgroundColor: const Color(0xFF0B0C10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Air Quality Card
  Widget _buildAirQualityCard(EnvironmentData envData) {
    final aqiColor = _getAqiColor(envData.airQuality);
    final aqiLevel = _getAqiLevel(envData.airQuality);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C23),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: aqiColor,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Air Quality Index',
                style: TextStyle(
                  color: Color(0xFFC5C6C7),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: aqiColor.withOpacity(0.2),
                  border: Border.all(color: aqiColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  aqiLevel,
                  style: TextStyle(
                    color: aqiColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // AQI Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (envData.airQuality / 500).clamp(0, 1),
              minHeight: 8,
              backgroundColor: const Color(0xFF0B0C10),
              valueColor: AlwaysStoppedAnimation<Color>(aqiColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AQI: ${envData.airQuality.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Scale: 0-500',
                style: TextStyle(
                  color: const Color(0xFFC5C6C7).withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Water Level Card
  Widget _buildWaterLevelCard(EnvironmentData envData) {
    final waterColor = envData.waterLevel > 0.7
        ? const Color(0xFF27AE60)
        : envData.waterLevel > 0.4
            ? const Color(0xFFF39C12)
            : const Color(0xFFE74C3C);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C23),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: waterColor,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.waves,
                color: Color(0xFFC5C6C7),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Water Level',
                style: TextStyle(
                  color: Color(0xFFC5C6C7),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF0B0C10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: waterColor.withOpacity(0.3),
              ),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 80 * envData.waterLevel,
                  decoration: BoxDecoration(
                    color: waterColor.withOpacity(0.2),
                  ),
                ),
                Center(
                  child: Text(
                    '${(envData.waterLevel * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: waterColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Level: ${envData.waterLevel.toStringAsFixed(2)}m',
            style: TextStyle(
              color: const Color(0xFFC5C6C7).withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  /// Audio Alert Button (ElevenLabs)
  Widget _buildAudioAlertButton(EnvironmentData envData) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFFC5C6C7), Color(0xFF8D8D8D)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC5C6C7).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _triggerAudioAlert(envData),
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.volume_up,
                color: Color(0xFF0B0C10),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Play Environment Alert (ElevenLabs)',
                style: TextStyle(
                  color: Color(0xFF0B0C10),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Trigger ElevenLabs audio playback
  void _triggerAudioAlert(EnvironmentData envData) {
    // Build alert message
    final alertMessage = _buildAlertMessage(envData);

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1C23),
        title: const Text(
          'Environment Alert',
          style: TextStyle(
            color: Color(0xFFC5C6C7),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          alertMessage,
          style: const TextStyle(
            color: Colors.white,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFFC5C6C7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('🔊 Playing audio alert via ElevenLabs...'),
                  backgroundColor: const Color(0xFFC5C6C7),
                  duration: const Duration(seconds: 3),
                ),
              );
              // TODO: Integrate actual ElevenLabs API call here
              // final elevenLabsService = ElevenLabsService();
              // elevenLabsService.playAlert(alertMessage);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC5C6C7),
              foregroundColor: const Color(0xFF0B0C10),
            ),
            child: const Text('Play Alert'),
          ),
        ],
      ),
    );
  }

  /// Build alert message from environment data
  String _buildAlertMessage(EnvironmentData envData) {
    return '''Current Environment Report

Location: ${envData.locationName}
Region: ${envData.region}

Climate Status: ${envData.climateStatus}
Temperature: ${envData.temperature.toStringAsFixed(1)}°C
Humidity: ${envData.humidity}%
Air Quality Index: ${envData.airQuality.toStringAsFixed(0)}
Water Level: ${envData.waterLevel.toStringAsFixed(2)}m

${_getAlertRecommendation(envData)}''';
  }

  /// Get alert recommendation based on climate status
  String _getAlertRecommendation(EnvironmentData envData) {
    switch (envData.climateStatus) {
      case 'CRITICAL':
        return 'WARNING: Critical conditions detected. Take immediate protective action and seek shelter.';
      case 'WARNING':
        return 'CAUTION: Adverse environmental conditions. Prepare protective measures and stay alert.';
      default:
        return 'SAFE: Environmental conditions are within safe parameters. Continue normal activities.';
    }
  }

  /// Helper: Build metric box
  Widget _buildMetricBox({
    required IconData icon,
    required String label,
    required String value,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFC5C6C7).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFC5C6C7), size: 18),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFFC5C6C7).withOpacity(0.7),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFF2F4F7),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper: Get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'CRITICAL':
        return const Color(0xFFE74C3C);
      case 'WARNING':
        return const Color(0xFFF39C12);
      default:
        return const Color(0xFF27AE60);
    }
  }

  /// Helper: Get status icon
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'CRITICAL':
        return Icons.warning_amber;
      case 'WARNING':
        return Icons.priority_high;
      default:
        return Icons.check_circle;
    }
  }

  /// Helper: Get status description
  String _getStatusDescription(String status) {
    switch (status) {
      case 'CRITICAL':
        return 'Extreme environmental conditions detected. Immediate protective action recommended.';
      case 'WARNING':
        return 'Adverse conditions present. Monitor closely and prepare protective measures.';
      default:
        return 'Environmental conditions are within safe parameters for survival activities.';
    }
  }

  /// Helper: Get AQI color
  Color _getAqiColor(double aqi) {
    if (aqi <= 50) return const Color(0xFF27AE60); // Good
    if (aqi <= 100) return const Color(0xFFF39C12); // Moderate
    if (aqi <= 150) return const Color(0xFFE67E22); // Unhealthy for sensitive
    if (aqi <= 200) return const Color(0xFFE74C3C); // Unhealthy
    if (aqi <= 300) return const Color(0xFFC0392B); // Very unhealthy
    return const Color(0xFF5B2C2C); // Hazardous
  }

  /// Helper: Get AQI level string
  String _getAqiLevel(double aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy (Sensitive)';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }
}
