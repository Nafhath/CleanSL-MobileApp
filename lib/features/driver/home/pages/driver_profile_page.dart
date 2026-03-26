import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/responsive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'report_history_screen.dart'; // Make sure this path points to Nafhath's history screen

class DriverProfilePage extends StatelessWidget {
  // Configurable parameters for different drivers
  final String driverName;
  final String employeeId;
  final String profileImageUrl;
  final String assignedDistrict;
  final String primaryVehicle;

  const DriverProfilePage({
    super.key,
    // Dummy details set as default fallbacks
    this.driverName = "Arjuna Perera",
    this.employeeId = "CMC-DR-402",
    this.profileImageUrl = "https://i.pravatar.cc/150?img=11", // Placeholder image
    this.assignedDistrict = "Colombo District 5",
    this.primaryVehicle = "Compactor Truck T-105",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.secondaryColor1, size: Responsive.w(context, 24)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My Profile",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.secondaryColor1,
                fontSize: Responsive.sp(context, 22),
              ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, AppTheme.space24),
            vertical: Responsive.h(context, AppTheme.space16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: Responsive.h(context, 16)),

              // 1. Profile Picture with Verification Badge
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: EdgeInsets.all(Responsive.w(context, 6)),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.secondaryColor1,
                        width: Responsive.w(context, 3),
                      ),
                    ),
                    child: CircleAvatar(
                      radius: Responsive.r(context, 55),
                      backgroundImage: NetworkImage(profileImageUrl),
                      backgroundColor: Colors.grey.shade300,
                    ),
                  ),
                  // Small Green Check Badge
                  Positioned(
                    bottom: Responsive.h(context, 4),
                    right: Responsive.w(context, 4),
                    child: Container(
                      padding: EdgeInsets.all(Responsive.w(context, 4)),
                      decoration: const BoxDecoration(
                        color: AppTheme.accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.secondaryColor2,
                        size: Responsive.w(context, 14),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: Responsive.h(context, 24)),

              // 2. Driver Name & Employee ID
              Text(
                driverName,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.textColor,
                      fontSize: Responsive.sp(context, 28),
                    ),
              ),
              SizedBox(height: Responsive.h(context, 8)),
              Text(
                "EMPLOYEE ID: $employeeId",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textColor.withValues(alpha: 0.5),
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                      fontSize: Responsive.sp(context, 12),
                    ),
              ),

              SizedBox(height: Responsive.h(context, 40)),

              // 3. Assigned District Card
              _buildInfoCard(
                context,
                title: "ASSIGNED DISTRICT",
                value: assignedDistrict,
                icon: Icons.location_on,
                statusText: "ACTIVE SECTOR",
              ),

              // 4. Primary Vehicle Card
              _buildInfoCard(
                context,
                title: "PRIMARY VEHICLE",
                value: primaryVehicle,
                icon: Icons.local_shipping_rounded,
                statusText: "REGISTERED",
              ),

              SizedBox(height: Responsive.h(context, 48)),

              // 5. Action Buttons
              _buildActionButton(
                context,
                text: "Report History",
                icon: Icons.history_rounded,
                color: AppTheme.secondaryColor1,
                onPressed: () {
                  // Route to Nafhath's History Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryScreen()),
                  );
                },
              ),
              
              SizedBox(height: Responsive.h(context, 24)),
              
              // Faint Divider Line
              Divider(color: AppTheme.textColor.withValues(alpha: 0.05), thickness: 1.5),
              
              SizedBox(height: Responsive.h(context, 24)),

              _buildActionButton(
                context,
                text: "Sign Out",
                icon: Icons.logout_rounded,
                color: const Color(0xFFC62828), // Deep red for destructive action
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  // Break the entire navigation stack and reset to the beginning
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/language', (route) => false);
                  }
                },
              ),
              
              SizedBox(height: Responsive.h(context, 32)),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build the flat white info cards
  Widget _buildInfoCard(BuildContext context, {required String title, required String value, required IconData icon, required String statusText}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: Responsive.h(context, 16)),
      padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 32), horizontal: Responsive.w(context, 24)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(context, 8)), // Slight radius matching the image
      ),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.secondaryColor1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  fontSize: Responsive.sp(context, 11),
                ),
          ),
          SizedBox(height: Responsive.h(context, 12)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textColor,
                  fontSize: Responsive.sp(context, 20),
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Responsive.h(context, 16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.accentColor, size: Responsive.w(context, 14)),
              SizedBox(width: Responsive.w(context, 6)),
              Text(
                statusText,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      fontSize: Responsive.sp(context, 10),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build the rounded action buttons
  Widget _buildActionButton(BuildContext context, {required String text, required IconData icon, required Color color, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: Responsive.h(context, 56),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.r(context, 30)),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: Responsive.w(context, 20)),
            SizedBox(width: Responsive.w(context, 12)),
            Text(
              text,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}