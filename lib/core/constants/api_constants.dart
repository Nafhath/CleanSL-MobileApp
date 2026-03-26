import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralised backend URL configuration.
/// Change API_BASE_URL in the .env file:
///   Real Android Device  → http://192.168.1.5:8000  (your PC's Wi-Fi IP)
///   Android Emulator     → http://10.0.2.2:8000
class ApiConstants {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000';

  static String get complaintsUrl => '$baseUrl/api/complaints';
  static String get scheduleUrl   => '$baseUrl/api/schedule';
  static String get notifyUrl     => '$baseUrl/api/notify';
  static String get driverReportsUrl => '$baseUrl/mobile/driver/reports';
  static String get mobileHealthUrl => '$baseUrl/mobile/health';
}
