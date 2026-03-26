import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = '';
  String _userPhone = '';
  String _userEmail = '';
  String _userAddress = '';
  bool _isLoadingProfile = true;

  // Mock State for the settings toggles
  bool _pushNotifications = true;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ─── Data Loading ──────────────────────────────────────────────────────────

  Future<void> _loadProfile() async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) return;

      final user = await client
          .from('users')
          .select('full_name, phone_number, email')
          .eq('id', userId)
          .single();

      final addr = await client
          .from('addresses')
          .select('street_address')
          .eq('resident_id', userId)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _userName    = user['full_name']    as String? ?? '';
          _userPhone   = user['phone_number'] as String? ?? '';
          _userEmail   = user['email']        as String? ?? '';
          _userAddress = addr?['street_address'] as String? ?? '';
          _isLoadingProfile = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  // ─── Navigation & Save ─────────────────────────────────────────────────────

  Future<void> _navigateToEditProfile() async {
    // Wait for the EditProfilePage to pop and return data
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(currentName: _userName, currentPhone: _userPhone, currentEmail: _userEmail, currentAddress: _userAddress),
      ),
    );

    // If the user hit "Save" (updatedData isn't null), update the UI!
    if (updatedData != null && mounted) {
      setState(() {
        _userName    = updatedData['name'];
        _userPhone   = updatedData['phone'];
        _userEmail   = updatedData['email'];
        _userAddress = updatedData['address'];
      });

      // Save to Supabase
      try {
        final client = Supabase.instance.client;
        final userId = client.auth.currentUser?.id;
        if (userId != null) {
          await client.from('users').update({
            'full_name':    _userName,
            'phone_number': _userPhone,
            'email':        _userEmail,
          }).eq('id', userId);

          final existingAddr = await client
              .from('addresses')
              .select('id')
              .eq('resident_id', userId)
              .maybeSingle();

          if (existingAddr != null) {
            await client.from('addresses').update({
              'street_address': _userAddress,
            }).eq('resident_id', userId);
          } else {
            await client.from('addresses').insert({
              'resident_id':    userId,
              'street_address': _userAddress,
            });
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully!")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Saved locally but DB error: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: Responsive.h(context, AppTheme.space64),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textColor, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text("Profile", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          // ADDED EDIT BUTTON
          TextButton(
            onPressed: _navigateToEditProfile,
            child: const Text(
              "Edit",
              style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, AppTheme.space24), vertical: Responsive.h(context, AppTheme.space16)),
        child: Column(
          children: [
            // 1. PROFILE HEADER (Image, Name, Location)
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: CircleAvatar(
                      radius: Responsive.r(context, 50),
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: const AssetImage('assets/img/profile_placeholder.jpg'),
                      onBackgroundImageError: (e, s) => {},
                      child: const Icon(Icons.person, size: 40, color: Colors.grey),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: _navigateToEditProfile, // Make camera icon tappable
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(context, 16)),
            // DYNAMIC NAME
            Text(_userName, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 24)),
            SizedBox(height: Responsive.h(context, 4)),
            Text(
              "Ward 7, Cinnamon Gardens",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryColor1.withValues(alpha: 0.7), fontWeight: FontWeight.w500),
            ),
            SizedBox(height: Responsive.h(context, 24)),

            // 2. STATS ROW
            Row(
              children: [
                Expanded(child: _buildStatCard("12", "TOTAL PICKUPS")),
                SizedBox(width: Responsive.w(context, 16)),
                Expanded(child: _buildStatCard("2", "REPORTS FILED")),
              ],
            ),
            SizedBox(height: Responsive.h(context, 32)),

            // 3. ACCOUNT DETAILS SECTION
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Account Details", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: Responsive.h(context, 16)),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  // DYNAMIC EMAIL
                  _buildInfoRow(Icons.email_outlined, "EMAIL", _userEmail),
                  const Divider(height: 1, color: Color(0xFFF3F4F6), indent: 56),
                  // DYNAMIC PHONE
                  _buildInfoRow(Icons.phone_outlined, "PHONE", _userPhone),
                  const Divider(height: 1, color: Color(0xFFF3F4F6), indent: 56),
                  // DYNAMIC ADDRESS
                  _buildInfoRow(Icons.location_on_outlined, "ADDRESS", _userAddress, isLast: true),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(context, 32)),

            // 4. SETTINGS SECTION
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Settings", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: Responsive.h(context, 16)),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildSettingsSwitch(Icons.notifications_none_rounded, "Push Notifications", _pushNotifications, (val) => setState(() => _pushNotifications = val)),
                  const Divider(height: 1, color: Color(0xFFF3F4F6), indent: 56),
                  _buildSettingsTile(Icons.language_rounded, "Language", "English"),
                  const Divider(height: 1, color: Color(0xFFF3F4F6), indent: 56),
                  _buildSettingsSwitch(Icons.dark_mode_outlined, "Dark Mode", _darkMode, (val) => setState(() => _darkMode = val), isLast: true),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(context, 32)),

            // 5. SIGN OUT BUTTON
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/language', (_) => false);
                  }
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                label: const Text(
                  "Sign Out",
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.2), width: 1.5),
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 16)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
              ),
            ),
            SizedBox(height: Responsive.h(context, 80)),
          ],
        ),
      ),
    );
  }

  // --- HELPERS ---

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppTheme.accentColor)),
          SizedBox(height: Responsive.h(context, 4)),
          Text(
            label,
            style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.all(Responsive.w(context, 20)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.accentColor, size: 24),
          SizedBox(width: Responsive.w(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.blueGrey.shade300, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                ),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSwitch(IconData icon, String title, bool value, ValueChanged<bool> onChanged, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 20), vertical: Responsive.h(context, 8)),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey.shade400, size: 24),
          SizedBox(width: Responsive.w(context, 16)),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.accentColor,
            activeTrackColor: AppTheme.accentColor.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String trailingText) {
    return Padding(
      padding: EdgeInsets.all(Responsive.w(context, 20)),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey.shade400, size: 24),
          SizedBox(width: Responsive.w(context, 16)),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          ),
          Text(trailingText, style: TextStyle(color: AppTheme.secondaryColor1.withValues(alpha: 0.7), fontSize: 14)),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, color: Colors.blueGrey.shade300, size: 20),
        ],
      ),
    );
  }
}
