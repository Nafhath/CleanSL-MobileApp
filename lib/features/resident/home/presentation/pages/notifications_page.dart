import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';
import '../../../../../../core/services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Keeps track of which filter is currently tapped
  String _selectedFilter = 'All';
  StreamSubscription<AppNotification>? _notifSub;
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Seed with demo data matching the backend payload shape
    _notifications = [
      AppNotification(
        title: 'Truck arriving in your zone',
        body: 'The waste collection truck is approximately 10 minutes away from your location. Please ensure bins are out.',
        type: 'pickup_alert',
        timestamp: now.subtract(const Duration(minutes: 2)),
        isNew: true,
      ),
      AppNotification(
        title: 'Complaint Resolved',
        body: 'Your report regarding "Missed Collection #4921" has been marked as resolved by the area supervisor.',
        type: 'complaint_resolved',
        timestamp: now.subtract(const Duration(hours: 4)),
        isNew: false,
      ),
      AppNotification(
        title: 'Collection delayed',
        body: 'Due to heavy rain, collection in Colombo 03 is delayed by 1 hour. We apologize for the inconvenience.',
        type: 'delay_alert',
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
        isNew: false,
      ),
      AppNotification(
        title: 'App Update Available',
        body: 'A new version of CleanSL is available with improved map tracking features. Update now.',
        type: 'app_update',
        timestamp: now.subtract(const Duration(days: 1, hours: 5)),
        isNew: false,
      ),
    ];
    // Live FCM listener: new messages are prepended at the top
    _notifSub = NotificationService.stream.listen((notif) {
      if (mounted) setState(() => _notifications.insert(0, notif));
    });
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    super.dispose();
  }

  // --- HELPERS ---

  List<AppNotification> _filtered() {
    if (_selectedFilter == 'Pickups') {
      return _notifications.where((n) => n.type == 'pickup_alert' || n.type == 'delay_alert').toList();
    }
    if (_selectedFilter == 'Issues') {
      return _notifications.where((n) => n.type == 'complaint_resolved').toList();
    }
    return _notifications;
  }

  bool _isToday(DateTime ts) {
    final now = DateTime.now();
    return ts.year == now.year && ts.month == now.month && ts.day == now.day;
  }

  bool _isYesterday(DateTime ts) {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return ts.year == y.year && ts.month == y.month && ts.day == y.day;
  }

  String _formatTime(DateTime ts) {
    final diffMins = DateTime.now().difference(ts).inMinutes;
    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return '$diffMins mins ago';
    if (_isToday(ts)) {
      final h = DateTime.now().difference(ts).inHours;
      return '$h hour${h == 1 ? '' : 's'} ago';
    }
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[ts.weekday - 1]}, ${ts.day} ${months[ts.month - 1]}';
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'pickup_alert':
        return Icons.local_shipping_rounded;
      case 'complaint_resolved':
        return Icons.check_circle_rounded;
      case 'delay_alert':
        return Icons.access_time_filled_rounded;
      case 'app_update':
        return Icons.system_update_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'pickup_alert':
        return Colors.blue.shade600;
      case 'complaint_resolved':
        return AppTheme.accentColor;
      case 'delay_alert':
        return Colors.orange.shade700;
      case 'app_update':
        return Colors.purple.shade500;
      default:
        return Colors.blueGrey;
    }
  }

  Color _bgColorForType(String type) {
    switch (type) {
      case 'pickup_alert':
        return Colors.blue.shade50;
      case 'complaint_resolved':
        return AppTheme.accentColor.withValues(alpha: 0.1);
      case 'delay_alert':
        return Colors.orange.shade50;
      case 'app_update':
        return Colors.purple.shade50;
      default:
        return Colors.blueGrey.withValues(alpha: 0.1);
    }
  }

  Widget _buildSection(BuildContext context, String header, List<AppNotification> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, AppTheme.space24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(header),
          SizedBox(height: Responsive.h(context, AppTheme.space16)),
          ...items.map(
            (n) => Padding(
              padding: EdgeInsets.only(bottom: Responsive.h(context, AppTheme.space16)),
              child: _buildNotificationCard(n),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground, // The cream background
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: Responsive.h(context, AppTheme.space64),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Notifications",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textColor),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Responsive.h(context, AppTheme.space32)),

            // 1. Scrollable Filter Chips
            _buildFiltersRow(),

            SizedBox(height: Responsive.h(context, AppTheme.space24)),

            // Dynamic notification sections, live-updated by FCM
            Builder(
              builder: (ctx) {
                final all = _filtered();
                final todayItems = all.where((n) => _isToday(n.timestamp)).toList();
                final yesterdayItems = all.where((n) => _isYesterday(n.timestamp)).toList();
                final earlierItems = all.where((n) => !_isToday(n.timestamp) && !_isYesterday(n.timestamp)).toList();
                return Column(
                  children: [
                    _buildSection(ctx, 'TODAY', todayItems),
                    if (todayItems.isNotEmpty && yesterdayItems.isNotEmpty) SizedBox(height: Responsive.h(context, AppTheme.space32)),
                    _buildSection(ctx, 'YESTERDAY', yesterdayItems),
                    if ((todayItems.isNotEmpty || yesterdayItems.isNotEmpty) && earlierItems.isNotEmpty) SizedBox(height: Responsive.h(context, AppTheme.space32)),
                    _buildSection(ctx, 'EARLIER', earlierItems),
                    if (all.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: Responsive.h(context, 80)),
                        child: Center(
                          child: Text('No notifications', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400)),
                        ),
                      ),
                    SizedBox(height: Responsive.h(context, AppTheme.space48)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildFiltersRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, AppTheme.space24)),
      child: Row(
        children: [
          _buildFilterChip(label: "All", icon: Icons.done_all_rounded, isSelected: _selectedFilter == 'All'),
          SizedBox(width: Responsive.w(context, 12)),
          _buildFilterChip(label: "Pickups", icon: Icons.local_shipping_rounded, isSelected: _selectedFilter == 'Pickups'),
          SizedBox(width: Responsive.w(context, 12)),
          _buildFilterChip(label: "Issues", icon: Icons.warning_rounded, isSelected: _selectedFilter == 'Issues'),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label, required IconData icon, required bool isSelected}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16), vertical: Responsive.h(context, 10)),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.textColor : Colors.white,
          borderRadius: BorderRadius.circular(Responsive.r(context, 24)),
          border: Border.all(color: isSelected ? AppTheme.textColor : Colors.grey.shade300, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: Responsive.w(context, 18), color: isSelected ? Colors.white : Colors.blueGrey.shade400),
            SizedBox(width: Responsive.w(context, 8)),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isSelected ? Colors.white : Colors.blueGrey.shade600, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: AppTheme.secondaryColor1.withValues(alpha: 0.8), // Dark green, slightly faded
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(context, 16)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Icon
          Container(
            padding: EdgeInsets.all(Responsive.w(context, 12)),
            decoration: BoxDecoration(color: _bgColorForType(notification.type), shape: BoxShape.circle),
            child: Icon(_iconForType(notification.type), color: _colorForType(notification.type), size: Responsive.w(context, 24)),
          ),
          SizedBox(width: Responsive.w(context, 16)),

          // Center Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textColor),
                      ),
                    ),
                    if (notification.isNew) ...[
                      SizedBox(width: Responsive.w(context, 8)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 8), vertical: Responsive.h(context, 4)),
                        decoration: BoxDecoration(color: Colors.red.shade600, borderRadius: BorderRadius.circular(Responsive.r(context, 12))),
                        child: Text(
                          'NEW',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: Responsive.sp(context, 10)),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: Responsive.h(context, 4)),
                Text(_formatTime(notification.timestamp), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.secondaryColor1.withValues(alpha: 0.6))),
                SizedBox(height: Responsive.h(context, 8)),
                Text(notification.body, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryColor1.withValues(alpha: 0.8), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
