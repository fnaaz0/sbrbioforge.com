import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'models/environment_model.dart';
import 'services/gps_service.dart';
import 'services/environment_service.dart';
import 'screens/environment_flow_screens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SbrBioForgeApp());
}

/// Main SBRBIOFORGE Application
class SbrBioForgeApp extends StatefulWidget {
  const SbrBioForgeApp({Key? key}) : super(key: key);

  @override
  State<SbrBioForgeApp> createState() => _SbrBioForgeAppState();
}

class _SbrBioForgeAppState extends State<SbrBioForgeApp> {
  late EnvironmentService _environmentService;
  late GpsService _gpsService;

  @override
  void initState() {
    super.initState();
    _environmentService = EnvironmentService();
    _gpsService = GpsService();
    
    // Initialize API keys from environment variables
    _environmentService.initializeApiKeys(
      openWeatherKey: const String.fromEnvironment(
        'OPENWEATHER_API_KEY',
        defaultValue: '',
      ),
      nasaKey: const String.fromEnvironment(
        'NASA_API_KEY',
        defaultValue: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SBRBIOFORGE',
      debugShowCheckedModeBanner: false,
      // 🖤 Black & Silver Premium Theme
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0B0C10), // Deep matte black
        primaryColor: const Color(0xFFC5C6C7), // Metallic silver
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          background: const Color(0xFF0B0C10),
          surface: const Color(0xFF1A1C23),
          primary: const Color(0xFFC5C6C7),
          secondary: const Color(0xFF8D8D8D),
          tertiary: const Color(0xFFF2F4F7),
          error: const Color(0xFFE74C3C),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          displayMedium: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFFC5C6C7),
            fontSize: 16,
            letterSpacing: 0.5,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF8D8D8D),
            fontSize: 14,
            letterSpacing: 0.3,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B0C10),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFFC5C6C7),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          iconTheme: IconThemeData(color: Color(0xFFC5C6C7)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC5C6C7),
            foregroundColor: const Color(0xFF0B0C10),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1C23),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFC5C6C7)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFC5C6C7), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFC5C6C7), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFFC5C6C7)),
          hintStyle: TextStyle(color: const Color(0xFFC5C6C7).withOpacity(0.6)),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

/// Welcome/Splash Screen
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late GpsService _gpsService;
  late EnvironmentService _environmentService;

  @override
  void initState() {
    super.initState();
    _gpsService = GpsService();
    _environmentService = EnvironmentService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🌐 App Logo with Silver Border
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFC5C6C7),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC5C6C7).withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.language_outlined,
                    size: 60,
                    color: Color(0xFFF2F4F7),
                  ),
                ),
                const SizedBox(height: 24),

                // Brand Name
                const Text(
                  'SBRBIOFORGE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),

                // Tagline
                const Text(
                  '300-Year Civilization Companion',
                  style: TextStyle(
                    color: Color(0xFFC5C6C7),
                    fontSize: 14,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),

                // Main Call-to-Action Button
                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC5C6C7), Color(0xFF8D8D8D)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC5C6C7).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _navigateToLanguageSelection(context),
                      borderRadius: BorderRadius.circular(30),
                      child: const Center(
                        child: Text(
                          'Choose Language / भाषा चुनें',
                          style: TextStyle(
                            color: Color(0xFF0B0C10),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Secondary Button - Start Detection
                OutlinedButton(
                  onPressed: () => _startEnvironmentDetection(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFC5C6C7), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_searching,
                        color: Color(0xFFC5C6C7),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Start Environment Detection',
                        style: TextStyle(
                          color: Color(0xFFC5C6C7),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Info Text
                Text(
                  'Offline-First • 300-Year Survival Data • Global Climate Intelligence',
                  style: TextStyle(
                    color: const Color(0xFFC5C6C7).withOpacity(0.6),
                    fontSize: 11,
                    letterSpacing: 0.8,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Navigate to language selection screen
  void _navigateToLanguageSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LanguageSelectionScreen(),
      ),
    );
  }

  /// Start GPS and environment detection
  void _startEnvironmentDetection(BuildContext context) async {
    // Request location permissions
    final permission = await _gpsService.requestLocationPermission();

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission is required. Please enable in settings.'),
            backgroundColor: Color(0xFFE74C3C),
          ),
        );
      }
      return;
    }

    if (permission != LocationPermission.denied && permission != LocationPermission.deniedForever) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EnvironmentFlowScreen(),
          ),
        );
      }
    }
  }
}

/// Language Selection Screen
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String selectedLanguage = 'English';

  final List<Map<String, String>> languages = [
    {'name': 'English', 'native': 'English', 'flag': '🇬🇧'},
    {'name': 'Hindi', 'native': 'हिंदी', 'flag': '🇮🇳'},
    {'name': 'Spanish', 'native': 'Español', 'flag': '🇪🇸'},
    {'name': 'Mandarin', 'native': '中文', 'flag': '🇨🇳'},
    {'name': 'French', 'native': 'Français', 'flag': '🇫🇷'},
    {'name': 'German', 'native': 'Deutsch', 'flag': '🇩🇪'},
    {'name': 'Portuguese', 'native': 'Português', 'flag': '🇵🇹'},
    {'name': 'Japanese', 'native': '日本語', 'flag': '🇯🇵'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0C10),
        elevation: 0,
        title: const Text(
          'Select Language',
          style: TextStyle(
            color: Color(0xFFC5C6C7),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC5C6C7)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final lang = languages[index];
                  final isSelected = selectedLanguage == lang['name'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedLanguage = lang['name']!;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1C23),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFC5C6C7)
                              : const Color(0xFFC5C6C7).withOpacity(0.3),
                          width: isSelected ? 2 : 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFC5C6C7).withOpacity(0.2),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            lang['flag']!,
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            lang['name']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lang['native']!,
                            style: TextStyle(
                              color: const Color(0xFFC5C6C7).withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _proceedWithLanguage(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC5C6C7),
                  foregroundColor: const Color(0xFF0B0C10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue with Selected Language',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _proceedWithLanguage(BuildContext context) {
    // Store language selection and proceed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🌍 Language set to: $selectedLanguage'),
        backgroundColor: const Color(0xFFC5C6C7),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(language: 'English'),
          ),
        );
      }
    });
  }
}

/// Main Dashboard Screen
class DashboardScreen extends StatefulWidget {
  final String language;

  const DashboardScreen({
    Key? key,
    required this.language,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late EnvironmentService _environmentService;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _environmentService = EnvironmentService();
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
          'SBRBIOFORGE CENTRAL',
          style: TextStyle(
            color: Color(0xFFC5C6C7),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFFC5C6C7)),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildDashboardContent(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1A1C23),
        selectedItemColor: const Color(0xFFC5C6C7),
        unselectedItemColor: const Color(0xFF8D8D8D),
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Environment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Guides',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const EnvironmentFlowScreen();
      case 2:
        return _buildGuidesTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1A1C23),
                  const Color(0xFF252A35),
                ],
              ),
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
                  'Welcome to SBRBIOFORGE',
                  style: TextStyle(
                    color: Color(0xFFC5C6C7),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your 300-year civilization survival companion. Access climate intelligence, water quality data, and air quality metrics.',
                  style: TextStyle(
                    color: const Color(0xFFC5C6C7).withOpacity(0.8),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildActionCard(
                icon: Icons.location_on,
                label: 'GPS Detection',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EnvironmentFlowScreen(),
                    ),
                  );
                },
              ),
              _buildActionCard(
                icon: Icons.cloud,
                label: 'Weather Data',
                onTap: () {},
              ),
              _buildActionCard(
                icon: Icons.waves,
                label: 'Water Levels',
                onTap: () {},
              ),
              _buildActionCard(
                icon: Icons.air,
                label: 'Air Quality',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1C23),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFC5C6C7).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFC5C6C7), size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFC5C6C7),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidesTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.library_books,
              size: 64,
              color: Color(0xFFC5C6C7),
            ),
            const SizedBox(height: 16),
            const Text(
              'Survival Guides',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Access 300-year civilization survival blueprints',
              style: TextStyle(
                color: const Color(0xFFC5C6C7).withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC5C6C7), width: 2),
              ),
              child: const Icon(
                Icons.person,
                size: 64,
                color: Color(0xFFC5C6C7),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'User Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Language: ${widget.language}',
              style: TextStyle(
                color: const Color(0xFFC5C6C7).withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
