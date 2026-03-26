import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 1. Import Supabase
import 'package:flutter_dotenv/flutter_dotenv.dart'; //  Import dotenv

import 'package:firebase_core/firebase_core.dart';
import 'core/services/notification_service.dart';
import 'core/services/firebase_options.dart';

// Import custom theme file
import 'core/theme/app_theme.dart';
// Import oboarding pages
import 'features/common/onboarding/presentation/pages/language_selection_page.dart';
import 'features/common/onboarding/presentation/pages/role_selection_page.dart';

// Import driver auth pages
import 'features/driver/driver_auth/presentation/pages/driver_login_page.dart';
import 'features/driver/driver_auth/presentation/pages/driver_otp_page.dart';

// Import resident auth pages
import 'features/resident/resident_auth/presentation/pages/resident_auth_hub_page.dart';
import 'features/resident/resident_auth/presentation/pages/resident_login_page.dart';
import 'features/resident/resident_auth/presentation/pages/resident_signup_page.dart';
import 'features/resident/resident_auth/presentation/pages/forgot_password_page.dart';
import 'features/resident/resident_auth/presentation/pages/forgot_password_verify_page.dart';
import 'features/resident/resident_auth/presentation/pages/reset_password_page.dart';

// Import resident main nav and other pages
import 'features/resident/home/presentation/pages/notifications_page.dart';
import 'features/resident/guide/presentation/pages/guide_main_page.dart';
import 'features/resident/main_nav/presentation/pages/resident_main_nav_page.dart';
import 'features/resident/guide/presentation/pages/organic_waste_page.dart';
import 'features/resident/guide/presentation/pages/recyclables_page.dart';
import 'features/resident/guide/presentation/pages/non_recyclable_page.dart';
import 'features/resident/home/presentation/pages/recent_activity_page.dart';

// Import driver main nav and other pages
import 'features/driver/home/pages/driver_home_page.dart';

// 2. Change main to be an asynchronous function
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow google_fonts to gracefully fall back to default fonts when offline
  GoogleFonts.config.allowRuntimeFetching = true;

  try {
    // 2. Load the .env file
    await dotenv.load(fileName: ".env");

    // 3. Initialize Firebase 
    if (!kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform, // <-- ADD THIS LINE
      );
    }

    // 4. Initialize Supabase using the hidden variables
    await Supabase.initialize(url: dotenv.env['SUPABASE_URL'] ?? '', anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '');

    // 5. Ask for notification permission and obtain this device's unique FCM token (mobile only)
    if (!kIsWeb) {
      await NotificationService.requestPermission();
      await NotificationService.getDeviceToken(); // token is printed to debug console
      NotificationService.listenForeground();
    }
  } catch (e) {
    debugPrint('Initialization error: $e');
  }

  // Determine the start route based on existing session AND user role
  String startRoute = '/language';
  try {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      // Check the user's role before routing — drivers go to driver-home
      final userId = session.user.id;
      final userRow = await Supabase.instance.client
          .from('users')
          .select('role')
          .eq('id', userId)
          .maybeSingle();
      final role = userRow?['role'] as String?;
      final phone = session.user.phone;

      // Drivers login via OTP, so their phone will be present. Residents use Email/Google.
      if (role == 'driver' || (phone != null && phone.isNotEmpty)) {
        startRoute = '/driver-home';
      } else {
        startRoute = '/resident-main';
      }
    }
  } catch (_) {}

  runApp(SmartResidentApp(initialRoute: startRoute));
}

// 4. Create a global variable for easy access to the client throughout your app
final supabase = Supabase.instance.client;

class SmartResidentApp extends StatelessWidget {
  final String initialRoute;

  const SmartResidentApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Removes the "Debug" banner from the top right corner
      debugShowCheckedModeBanner: false,

      title: 'Smart Resident',

      // Using your custom brand guidelines from app_theme.dart
      theme: AppTheme.lightTheme,

      // Auto-login: use the determined initial route
      initialRoute: initialRoute,

      // Define the routes for navigation
      routes: {
        // Onboarding flow
        '/language': (context) => const LanguageSelectionPage(),
        '/role': (context) => const RoleSelectionPage(),

        // Driver Auth flow
        '/driver-login': (context) => const DriverLoginPage(),
        '/driver-otp': (context) => const DriverOtpPage(),

        // Resident Auth flow
        '/resident-auth-hub': (context) => const ResidentAuthHubPage(),
        '/resident-login': (context) => const ResidentLoginPage(),
        '/resident-signup': (context) => const ResidentSignUpPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/forgot-password-verify': (context) => const ForgotPasswordVerifyPage(),
        '/reset-password': (context) => const ResetPasswordPage(),

        // Resident Main Navigation and other pages 
        '/resident-main': (context) => const ResidentMainNavPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/guide': (context) => const GuideMainPage(),
        '/organic-waste': (context) => const OrganicWastePage(),
        '/recyclables': (context) => const RecyclablesPage(),
        '/non-recyclables': (context) => const NonRecyclablePage(),
        '/recent-activity': (context) => const RecentActivityPage(),

        // Driver Main Navigation and other pages
        '/driver-home': (context) => const DriverHomePage(),
      },
    );
  }
}