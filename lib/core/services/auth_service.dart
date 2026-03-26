import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ResidentSignUpResult {
  const ResidentSignUpResult({
    required this.signedIn,
    required this.requiresEmailConfirmation,
    this.email,
  });

  final bool signedIn;
  final bool requiresEmailConfirmation;
  final String? email;
}

class AuthService {
  // The global Supabase connection
  final _supabase = Supabase.instance.client;

  // ==========================================
  // RESIDENT AUTHENTICATION (EMAIL/MOBILE)
  // ==========================================

  Future<ResidentSignUpResult> signUpResident({
    required String fullName,
    required String mobile,
    required String email,
    required String password,
  }) async {
    final AuthResponse response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone_number': mobile,
        'role': 'resident',
      },
    );

    final user = response.user;
    if (user == null) {
      throw Exception("Unable to create account. Please try again.");
    }

    if (response.session != null) {
      await _ensureResidentRows(
        userId: user.id,
        fullName: fullName,
        mobile: mobile,
        email: email,
      );
      return const ResidentSignUpResult(
        signedIn: true,
        requiresEmailConfirmation: false,
      );
    }

    return ResidentSignUpResult(
      signedIn: false,
      requiresEmailConfirmation: true,
      email: email,
    );
  }

  Future<void> signInResident({required String identifier, required String password}) async {
    String loginEmail = identifier;

    if (identifier.contains('@')) {
      loginEmail = identifier;
    } else {
      final response = await _supabase.from('users').select('email').eq('phone_number', identifier).eq('role', 'resident').maybeSingle();

      if (response == null) {
        throw Exception("No resident account found with this mobile number.");
      }
      loginEmail = response['email'];
    }

    try {
      await _supabase.auth.signInWithPassword(email: loginEmail, password: password);
      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null) {
        final metadata = currentUser.userMetadata ?? const <String, dynamic>{};
        await _ensureResidentRows(
          userId: currentUser.id,
          fullName: metadata['full_name']?.toString(),
          mobile: metadata['phone_number']?.toString(),
          email: currentUser.email ?? loginEmail,
        );
      }
    } on AuthException catch (e) {
      if (e.message == 'Invalid login credentials') {
        throw Exception("Incorrect password. Please try again.");
      }
      if (e.message.toLowerCase().contains('email not confirmed')) {
        throw Exception("Please verify your email before signing in.");
      }
      throw Exception(e.message);
    }
  }

  // ==========================================
  // GOOGLE AUTHENTICATION (v7.2.0 COMPLIANT)
  // ==========================================

  Future<void> signInWithGoogle() async {
    final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];

    if (webClientId == null) {
      throw Exception('Missing GOOGLE_WEB_CLIENT_ID in .env file');
    }

    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(clientId: webClientId, serverClientId: webClientId);

    final scopes = ['email', 'profile'];

    await googleSignIn.signOut();
    final googleUser = await googleSignIn.authenticate(scopeHint: scopes);

    final authorization = await googleUser.authorizationClient.authorizationForScopes(scopes) ?? await googleUser.authorizationClient.authorizeScopes(scopes);

    final idToken = googleUser.authentication.idToken;
    final accessToken = authorization.accessToken;

    if (idToken == null) {
      throw Exception('Failed to retrieve Google ID token.');
    }

    final response = await _supabase.auth.signInWithIdToken(provider: OAuthProvider.google, idToken: idToken, accessToken: accessToken);

    final user = response.user;

    if (user != null) {
      await _ensureResidentRows(
        userId: user.id,
        fullName: user.userMetadata?['full_name']?.toString() ?? 'Google User',
        email: user.email ?? '',
      );
    }
  }

  // ==========================================
  // DRIVER AUTHENTICATION (OTP FLOW)
  // ==========================================

  Future<void> sendDriverOTP({required String mobile}) async {
    final driverCheck = await _supabase.from('users').select('id').eq('phone_number', mobile).eq('role', 'driver').maybeSingle();

    if (driverCheck == null) {
      throw Exception("No authorized driver account found for this number.");
    }

    final formattedNumber = '+94$mobile';
    await _supabase.auth.signInWithOtp(phone: formattedNumber);
  }

  Future<void> verifyDriverOTP({required String mobile, required String token}) async {
    final formattedNumber = '+94$mobile';
    debugPrint('[DriverAuth] Verifying OTP for $formattedNumber — token: $token');

    try {
      final AuthResponse response = await _supabase.auth.verifyOTP(
        phone: formattedNumber,
        token: token,
        type: OtpType.sms,
      );
      debugPrint('[DriverAuth] Success — user: ${response.user?.id}');
      if (response.user == null) {
        throw Exception("Verification failed. Please try again.");
      }
    } on AuthException catch (e) {
      debugPrint('[DriverAuth] AuthException: ${e.message} (status: ${e.statusCode})');
      throw Exception("Invalid OTP — ${e.message}");
    }
  }

  Future<void> _ensureResidentRows({
    required String userId,
    String? fullName,
    String? mobile,
    String? email,
  }) async {
    await _supabase.from('users').upsert({
      'id': userId,
      'role': 'resident',
      'full_name': (fullName == null || fullName.trim().isEmpty) ? 'Resident User' : fullName.trim(),
      'phone_number': mobile,
      'email': email,
    });

    await _supabase.from('resident_profiles').upsert({
      'user_id': userId,
      'total_points': 0,
    });
  }
}
