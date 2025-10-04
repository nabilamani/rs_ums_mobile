import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rs_ums_test/firebase_options.dart';
import 'package:rs_ums_test/screens/onboarding_screen.dart';
import 'package:rs_ums_test/screens/login_screen.dart';
import 'package:rs_ums_test/screens/akun_page.dart';
import 'package:rs_ums_test/screens/home_screen.dart';
import 'package:rs_ums_test/screens/jadwal_page.dart';
import 'package:rs_ums_test/screens/presensi_page.dart';
import 'package:rs_ums_test/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize date formatting untuk bahasa Indonesia
  await initializeDateFormatting('id_ID', null);
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Check if onboarding has been completed
  bool hasSeenOnboarding = false;
  try {
    final prefs = await SharedPreferences.getInstance();
    hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  } catch (e) {
    debugPrint('Error loading preferences: $e');
    hasSeenOnboarding = false;
  }
  
  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  
  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RS UMS Mobile',
      theme: ThemeData(
        // Primary colors
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          error: AppColors.error,
        ),
        
        // AppBar theme
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        // BottomNavigationBar theme
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
          ),
        ),
        
        // Button themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
          ),
        ),
        
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
        ),
        
        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 1,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMedium,
            vertical: 12,
          ),
        ),
        
        // Divider theme
        dividerTheme: const DividerThemeData(
          color: Colors.grey,
          thickness: 0.5,
        ),
        
        // Use Material 3
        useMaterial3: true,
      ),
      // Show onboarding or login based on preference
      home: hasSeenOnboarding ? const LoginScreen() : const OnboardingScreen(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainPage(),
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  
  // Page controller untuk smooth transition
  final PageController _pageController = PageController();

  final List<Widget> _pages = const [
    HomePage(),
    JadwalPage(),
    PresensiPage(),
    AkunPage(),
  ];
  
  final List<NavigationItem> _navigationItems = const [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: "Home",
    ),
    NavigationItem(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
      label: "Jadwal",
    ),
    NavigationItem(
      icon: Icons.fingerprint_outlined,
      activeIcon: Icons.fingerprint,
      label: "Presensi",
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: "Akun",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
            ),
            items: _navigationItems.map((item) {
              final isSelected = _navigationItems[_currentIndex] == item;
              return BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(isSelected ? item.activeIcon : item.icon),
                ),
                label: item.label,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// Model untuk navigation items
class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}