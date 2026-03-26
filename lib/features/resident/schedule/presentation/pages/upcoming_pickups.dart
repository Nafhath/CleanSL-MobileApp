import 'dart:ui'; // Required for the blur effect
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';

class PickupDetailsPage extends StatefulWidget {
  // --- TEMPLATE PARAMETERS ---
  final String statusLabel; // e.g., "UPCOMING"
  final String title; // e.g., "Non-Recyclables Pickup"
  final String date;
  final String time;
  final String wasteType;
  final Color themeColor; // Drives the color of badges, icons, and buttons
  final IconData wasteIcon; // e.g., Icons.delete_outline_rounded
  final List<String> disposalTips;
  final bool initialReminderSet;
  final ValueChanged<bool>? onReminderChanged;

  const PickupDetailsPage({
    super.key,
    required this.statusLabel,
    required this.title,
    required this.date,
    required this.time,
    required this.wasteType,
    required this.themeColor,
    required this.wasteIcon,
    required this.disposalTips,
    this.initialReminderSet = false,
    this.onReminderChanged,
  });

  @override
  State<PickupDetailsPage> createState() => _PickupDetailsPageState();
}

class _PickupDetailsPageState extends State<PickupDetailsPage> {
  late bool _isReminderSet;

  @override
  void initState() {
    super.initState();
    _isReminderSet = widget.initialReminderSet;
  }

  void _setReminder(bool value) {
    if (_isReminderSet == value) return;
    setState(() {
      _isReminderSet = value;
    });
    widget.onReminderChanged?.call(value);
  }

  // --- THE BLURRED REMINDER DIALOG LOGIC ---
  void _showReminderDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.1), // Light dark overlay
      builder: (BuildContext context) {
        // BackdropFilter creates the glass/blur effect behind the dialog
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            insetPadding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24)),
            child: Padding(
              padding: EdgeInsets.all(Responsive.w(context, 24)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: widget.themeColor, shape: BoxShape.circle),
                        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 16),
                      ),
                      SizedBox(width: Responsive.w(context, 12)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("CLEANSL", style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                          Text("Just now", style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.more_horiz_rounded, color: Colors.grey.shade400),
                    ],
                  ),
                  SizedBox(height: Responsive.h(context, 20)),

                  // Text Content
                  Text("Reminder: ${widget.title.replaceAll('General Waste', 'Non-Recyclables')}", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: Responsive.h(context, 8)),
                  Text(
                    "The truck will be at your location at ${widget.time} tomorrow. Please ensure your bin is at the curb.",
                    style: TextStyle(color: Colors.grey.shade600, height: 1.4, fontSize: 14),
                  ),
                  SizedBox(height: Responsive.h(context, 24)),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // 1. Update the state to turn the bell active
                            _setReminder(true);
                            // 2. Close Dialog
                            Navigator.pop(context);
                            // 3. Show confirmation snackbar
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reminder turned ON")));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.themeColor, // Dynamically matches template
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 14)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text(
                            "Confirm",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(width: Responsive.w(context, 12)),
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFF3F4F6),
                            padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 14)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text(
                            "Dismiss",
                            style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: Responsive.h(context, AppTheme.space64),
        title: Text("Pickup Details", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textColor, size: 20),
            onPressed: () => Navigator.pop(context, _isReminderSet),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.w(context, AppTheme.space24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP MAP (Static preview)
            SizedBox(
              height: Responsive.h(context, 180),
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const GoogleMap(
                      initialCameraPosition: CameraPosition(target: LatLng(6.9061, 79.8687), zoom: 14.5),
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      mapToolbarEnabled: false,
                      compassEnabled: false,
                    ),
                    Icon(Icons.location_on_rounded, size: 48, color: widget.themeColor),
                  ],
                ),
              ),
            ),
            SizedBox(height: Responsive.h(context, 24)),

            // 2. STATUS BADGE & TITLE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: widget.themeColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Text(
                widget.statusLabel,
                style: TextStyle(color: widget.themeColor, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.1),
              ),
            ),
            SizedBox(height: Responsive.h(context, 12)),
            Text(widget.title.replaceAll('General Waste', 'Non-Recyclables'), style: Theme.of(context).textTheme.displaySmall),
            SizedBox(height: Responsive.h(context, 24)),

            // 3. DETAILS CARDS
            _buildDetailCard(Icons.calendar_today_rounded, "DATE", widget.date, widget.themeColor),
            SizedBox(height: Responsive.h(context, 16)),
            _buildDetailCard(Icons.access_time_rounded, "TIME", widget.time, widget.themeColor),
            SizedBox(height: Responsive.h(context, 16)),
            _buildDetailCard(widget.wasteIcon, "WASTE TYPE", widget.wasteType, widget.themeColor),
            SizedBox(height: Responsive.h(context, 32)),

            // 4. DYNAMIC REMINDER BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_isReminderSet) {
                    // Turn it off if already set
                    _setReminder(false);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reminder cancelled")));
                  } else {
                    // Show the confirmation dialog
                    _showReminderDialog();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.themeColor, // Adopts the template color!
                  foregroundColor: Colors.white,
                  shadowColor: widget.themeColor.withValues(alpha: 0.2),
                  elevation: 8,
                  padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 16)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_isReminderSet ? Icons.notifications_active_rounded : Icons.notifications_rounded, color: Colors.white),
                    SizedBox(width: Responsive.w(context, 12)),
                    Text(
                      _isReminderSet ? "Reminder Set" : "Set Reminder",
                      style: TextStyle(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: Responsive.h(context, 32)),

            // 5. DISPOSAL TIPS
            Row(
              children: [
                Icon(Icons.lightbulb_rounded, color: widget.themeColor),
                const SizedBox(width: 8),
                Text("Disposal Tips", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: Responsive.h(context, 16)),
            ...widget.disposalTips.map((tip) => _buildTipRow(tip, widget.themeColor)),
          ],
        ),
      ),
    );
  }

  // --- HELPERS ---
  Widget _buildDetailCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(context, 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: Responsive.w(context, 16)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.blueGrey.shade300, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1),
              ),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipRow(String tip, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(context, 16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(Icons.check_rounded, color: color, size: 14),
          ),
          SizedBox(width: Responsive.w(context, 12)),
          Expanded(
            child: Text(tip, style: TextStyle(color: AppTheme.textColor.withValues(alpha: 0.8), height: 1.4, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
