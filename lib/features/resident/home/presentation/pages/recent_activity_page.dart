import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';
import '../../../complaints/data/complaint_model.dart';
import '../../../complaints/presentation/pages/complaint_details_page.dart';
import '../../../schedule/presentation/pages/completed_pickup_page.dart';

// --- 1. DATA MODELS ---
class CompletedPickupInfo {
  final String title;
  final String subtitle;
  final String imagePath;
  final String certificateId;
  final String date;
  final String location;
  final String wasteType;
  final String collectedBy;
  final String impactMessage;
  final Color themeColor;
  final IconData impactIcon;

  CompletedPickupInfo({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.certificateId,
    required this.date,
    required this.location,
    required this.wasteType,
    required this.collectedBy,
    required this.impactMessage,
    required this.themeColor,
    required this.impactIcon,
  });
}

class ActivityItem {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String category; 
  final String? statusText;
  final List<Map<IconData, String>> details;
  final String actionText;
  final Complaint? complaint;
  final CompletedPickupInfo? completedPickup; 

  ActivityItem({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.category,
    this.statusText,
    required this.details,
    required this.actionText,
    this.complaint,
    this.completedPickup,
  });
}

class RecentActivityPage extends StatefulWidget {
  const RecentActivityPage({super.key});

  @override
  State<RecentActivityPage> createState() => _RecentActivityPageState();
}

class _RecentActivityPageState extends State<RecentActivityPage> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  // --- 2. THE DATA SOURCE (Aligned with Schedule Page) ---
  final List<ActivityItem> _allActivities = [
    // 1. RECYCLING PICKUP
    ActivityItem(
      title: "Recycling Pickup Completed",
      icon: Icons.recycling_rounded,
      iconColor: AppTheme.accentColor,
      iconBgColor: AppTheme.accentColor.withValues(alpha: 0.15),
      category: 'Pickups',
      details: [
        {Icons.calendar_today_rounded: "Oct 07, 2023 • 09:15 AM"},
        {Icons.location_on_rounded: "42nd Lane, Wellawatte"},
      ],
      actionText: "VIEW DETAILS",
      completedPickup: CompletedPickupInfo(
        title: "Successfully Collected",
        subtitle: "Your recyclable materials have been sorted and sent to processing facilities.",
        imagePath: 'assets/img/recyclable_waste.jpg',
        certificateId: "#CSL-REC-8821",
        date: "October 07, 2023 • 09:15 AM",
        location: "42nd Lane, Wellawatte",
        wasteType: "Recyclables (Metal/Glass)",
        collectedBy: "EcoCollector Team B-12",
        impactMessage: "You helped save 45 liters of water and 12 kWh of energy through recycling!",
        themeColor: AppTheme.accentColor,
        impactIcon: Icons.water_drop_rounded,
      ),
    ),
    // 2. COMPLAINT
    ActivityItem(
      title: "Issue Reported: Overflowing Bin",
      icon: Icons.warning_rounded,
      iconColor: Colors.orange.shade700,
      iconBgColor: Colors.orange.shade50,
      category: 'Reports',
      statusText: "IN PROGRESS",
      details: [
        {Icons.numbers_rounded: "Reference ID: #8795"},
      ],
      actionText: "TRACK STATUS",
      complaint: Complaint(
        id: "8795",
        dbId: "8795",
        category: "Overflowing Bin",
        status: "In Progress",
        statusTitle: "Team Assigned",
        statusDescription: "A field team has been dispatched to resolve the issue.",
        dateSubmitted: "Oct 10, 2023",
        fullDescription: "Public bin at the corner of 5th Ave is overflowing and causing a health hazard.",
        imagePath: 'assets/img/overflowing_bin.jpg',
        isLocal: true,
        assignedTo: "Field Team B",
      ),
    ),
    // 3. ORGANIC WASTE PICKUP (Synced with Schedule Page)
    ActivityItem(
      title: "Organic Waste Collected",
      icon: Icons.eco_rounded, 
      iconColor: AppTheme.accentColor,
      iconBgColor: AppTheme.accentColor.withValues(alpha: 0.15),
      category: 'Pickups',
      details: [
        {Icons.calendar_today_rounded: "Oct 04, 2023 • 08:45 AM"},
        {Icons.location_on_rounded: "42nd Lane, Wellawatte"},
      ],
      actionText: "RECEIPT",
      completedPickup: CompletedPickupInfo(
        title: "Successfully Collected",
        subtitle: "Your organic waste has been processed and is ready for composting.",
        imagePath: 'assets/img/organic_waste.jpg',
        certificateId: "#CSL-ORG-2231",
        date: "October 04, 2023 • 08:45 AM",
        location: "42nd Lane, Wellawatte",
        wasteType: "Organic Waste",
        collectedBy: "EcoCollector Team B-12",
        impactMessage: "This collection prevented approx. 1.8kg of CO2 equivalent from entering the atmosphere.",
        themeColor: AppTheme.accentColor,
        impactIcon: Icons.eco_rounded,
      ),
    ),
    // 4. RESOLVED COMPLAINT
    ActivityItem(
      title: "Report Resolved: Broken Bin",
      icon: Icons.check_circle_rounded,
      iconColor: AppTheme.accentColor,
      iconBgColor: AppTheme.accentColor.withValues(alpha: 0.15),
      category: 'Reports',
      statusText: "RESOLVED",
      details: [
        {Icons.verified_rounded: "Action: Bin Replaced"},
      ],
      actionText: "FEEDBACK",
      complaint: Complaint(
        id: "8612",
        dbId: "8612",
        category: "Broken Bin",
        status: "Resolved",
        statusTitle: "Replacement Completed",
        statusDescription: "A replacement bin has been delivered and the damaged bin collected.",
        dateSubmitted: "Oct 05, 2023",
        fullDescription: "My household bin has a large crack along the side and a broken wheel.",
        imagePath: 'assets/img/broken_bin.jpg',
        isLocal: true,
        completionDate: "Oct 07",
      ),
    ),
  ];

  List<ActivityItem> get _filteredActivities {
    return _allActivities.where((activity) {
      final matchesCategory = _selectedFilter == 'All' || activity.category == _selectedFilter;
      final matchesSearch = activity.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
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
        title: Text(
          "Recent Activity",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textColor),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textColor),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, AppTheme.space24)),
            child: _buildSearchBar(),
          ),
          const SizedBox(height: 16),
          _buildFiltersRow(),
          const SizedBox(height: 24),
          Expanded(
            child: _filteredActivities.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, AppTheme.space24)),
                    itemCount: _filteredActivities.length,
                    itemBuilder: (context, index) => _buildActivityCard(context, _filteredActivities[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.r(context, 12)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: "Search activities...",
          prefixIcon: Icon(Icons.search_rounded, color: Colors.blueGrey.shade300),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildFiltersRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, AppTheme.space24)),
      child: Row(
        children: [
          _buildFilterChip(label: 'All', icon: Icons.done_all_rounded, isSelected: _selectedFilter == 'All'),
          const SizedBox(width: 12),
          _buildFilterChip(label: 'Pickups', icon: Icons.local_shipping_rounded, isSelected: _selectedFilter == 'Pickups'),
          const SizedBox(width: 12),
          _buildFilterChip(label: 'Reports', icon: Icons.warning_rounded, isSelected: _selectedFilter == 'Reports'),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label, required IconData icon, required bool isSelected}) {
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
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
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? Colors.white : Colors.blueGrey.shade600, 
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, ActivityItem item) {
    // 1. Function declaration for tap handling
    void handleTap() {
      if (item.complaint != null) {
        _openComplaintDetails(context, item.complaint!);
      } else if (item.completedPickup != null) {
        _openCompletedPickupDetails(context, item.completedPickup!);
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: handleTap,
        borderRadius: BorderRadius.circular(Responsive.r(context, 16)),
        child: Container(
          margin: EdgeInsets.only(bottom: Responsive.h(context, AppTheme.space16)),
          padding: EdgeInsets.all(Responsive.w(context, 20)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Responsive.r(context, 16)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(Responsive.w(context, 12)),
                    decoration: BoxDecoration(color: item.iconBgColor, shape: BoxShape.circle),
                    child: Icon(item.icon, color: item.iconColor, size: Responsive.w(context, 24)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textColor),
                        ),
                        if (item.statusText != null) ...[
                          const SizedBox(height: 8), 
                          _buildStatusPill(item.statusText!, item.iconColor, item.iconBgColor)
                        ],
                        const SizedBox(height: 12),
                        ...item.details.map((detail) {
                          final entry = detail.entries.first;
                          return _buildDetailRow(entry.key, entry.value);
                        }),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end, 
                children: [_buildActionButton(item.actionText, handleTap)],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(String text, Color color, Color bg) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 8), vertical: Responsive.h(context, 4)),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Responsive.r(context, 6))),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.h(context, 6)),
      child: Row(
        children: [
          Icon(icon, size: Responsive.w(context, 16), color: Colors.blueGrey.shade400),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blueGrey.shade600)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16), vertical: Responsive.h(context, 8)),
        decoration: BoxDecoration(color: AppTheme.accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(Responsive.r(context, 20))),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.accentColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text("No activities found matching your criteria.", style: TextStyle(color: Colors.grey.shade500)),
    );
  }

  void _openComplaintDetails(BuildContext context, Complaint complaint) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ComplaintDetailsPage(complaint: complaint)));
  }

  void _openCompletedPickupDetails(BuildContext context, CompletedPickupInfo info) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompletedPickupDetailsPage(
          title: info.title,
          subtitle: info.subtitle,
          imagePath: info.imagePath,
          certificateId: info.certificateId,
          date: info.date,
          location: info.location,
          wasteType: info.wasteType,
          collectedBy: info.collectedBy,
          impactMessage: info.impactMessage,
          themeColor: info.themeColor,
          impactIcon: info.impactIcon,
        ),
      ),
    );
  }
}