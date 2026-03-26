import 'dart:async'; // Need this for StreamSubscription
import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';
import '../../../../../../core/services/notification_service.dart';
import '../../../home/presentation/pages/resident_home_page.dart';
import '../../../complaints/presentation/pages/complaints_main_page.dart';
import '../../../schedule/presentation/pages/schedule_main_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class ResidentMainNavPage extends StatefulWidget {
  const ResidentMainNavPage({super.key});

  @override
  State<ResidentMainNavPage> createState() => _ResidentMainNavPageState();
}

class _ResidentMainNavPageState extends State<ResidentMainNavPage> {
  int _currentIndex = 0;
  
  // Create a variable to hold our subscription so we can close it if the page is ever destroyed
  StreamSubscription<AppNotification>? _notificationSubscription;

  final List<Widget> _screens = [
    const ResidentHomePage(),
    const ScheduleMainPage(),
    const ComplaintsMainPage(),
    const ProfilePage(),
  ];

  // 1. Define your icons and labels in simple lists
  final List<IconData> _icons = [
    Icons.home_rounded, 
    Icons.calendar_month_rounded, 
    Icons.document_scanner_rounded, 
    Icons.person_rounded
  ];

  final List<String> _labels = ["Home", "Schedule", "Complaints", "Profile"];

  @override
  void initState() {
    super.initState();
    
    // --- NOTIFICATION LISTENER ---
    // This listens for push notifications while the app is actively open on the screen
    _notificationSubscription = NotificationService.stream.listen((AppNotification notification) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: const TextStyle(color: Colors.white, fontSize: 14)
                ),
              ],
            ),
            backgroundColor: AppTheme.secondaryColor1, // Dark Green Background
            behavior: SnackBarBehavior.floating, // Makes it float above the bottom nav bar
            margin: EdgeInsets.only(
              bottom: Responsive.h(context, 100), // Push it above your custom nav bar
              left: Responsive.w(context, 20),
              right: Responsive.w(context, 20),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'View',
              textColor: AppTheme.hoverColor,
              onPressed: () {
                // Optional: If they click "View", jump to the Notifications tab/page
                // Navigator.pushNamed(context, '/notifications');
              },
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    // Clean up the subscription when the widget dies to prevent memory leaks
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomSafe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),

      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: Responsive.w(context, AppTheme.space16), // Slightly tighter to fit the horizontal text
          right: Responsive.w(context, AppTheme.space16),
          bottom: Responsive.h(context, AppTheme.space24) + bottomSafe,
        ),
        child: Container(
          // Inner padding for the whole nav bar
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, AppTheme.space8), vertical: Responsive.h(context, AppTheme.space8)),
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor1.withValues(alpha: 0.95), // The dark green background
            borderRadius: BorderRadius.circular(Responsive.r(context, 40)),
            boxShadow: [BoxShadow(color: AppTheme.accentColor.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          // 2. Custom Row instead of BottomNavigationBar
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_icons.length, (index) {
              final isSelected = _currentIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                // 3. AnimatedContainer handles the smooth expansion when clicked
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(horizontal: isSelected ? Responsive.w(context, 16) : Responsive.w(context, 12), vertical: Responsive.h(context, 12)),
                  decoration: BoxDecoration(
                    // Lighter background only for the active item
                    color: isSelected ? AppTheme.accentColor.withValues(alpha: 0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(Responsive.r(context, 30)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_icons[index], color: isSelected ? AppTheme.hoverColor : Colors.white54, size: Responsive.w(context, 24)),
                      // 4. Smoothly show text only if selected
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        child: SizedBox(
                          width: isSelected ? null : 0,
                          child: Row(
                            children: [
                              SizedBox(width: Responsive.w(context, 8)),
                              Text(
                                _labels[index],
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.hoverColor, fontSize: Responsive.sp(context, 14)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}