import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Make sure to add 'intl' to your pubspec.yaml if you haven't!
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/responsive.dart';
import '../data/bambalapitiya_routes.dart';
import '../data/route_model.dart';
import 'lane_houses_page.dart';

class BambalapitiyaRoutePage extends StatefulWidget {
  const BambalapitiyaRoutePage({super.key});

  @override
  State<BambalapitiyaRoutePage> createState() => _BambalapitiyaRoutePageState();
}

class _BambalapitiyaRoutePageState extends State<BambalapitiyaRoutePage> {
  // VIVA PROTOTYPE: Hardcoded to Truck 1.
  final String _currentTruckId = "Truck 1";

  List<String> _assignedLanes = [];
  String _currentWasteType = "No Scheduled Pickup";
  String _currentSector = "";

  @override
  void initState() {
    super.initState();
    _loadTodayRoute();
  }

  void _loadTodayRoute() {
    // 1. Get today's day abbreviation (e.g., "Mon", "Tue", "Fri")
    String todayStr = DateFormat('E').format(DateTime.now());

    // 2. Search the dataset for a match for THIS truck on THIS day
    RouteSchedule? todaySchedule;

    for (var schedule in BambalapitiyaData.allRoutes) {
      if (schedule.truckId == _currentTruckId && schedule.days.contains(todayStr)) {
        todaySchedule = schedule;
        break;
      }
    }

    // 3. Update the UI state with the findings
    if (todaySchedule != null) {
      setState(() {
        _assignedLanes = todaySchedule!.lanes;
        _currentWasteType = todaySchedule.wasteType;
        _currentSector = todaySchedule.sector;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.secondaryColor1),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: Responsive.h(context, 16)),

            // Render the Lane List (or an empty state if no route today)
            Expanded(child: _assignedLanes.isEmpty ? _buildEmptyState(context) : _buildLaneList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bambalapitiya Route",
            style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppTheme.secondaryColor1, fontSize: Responsive.sp(context, 28)),
          ),
          SizedBox(height: Responsive.h(context, 12)),

          // Subtitle Row with Lane Count and Waste Type
          Row(
            children: [
              Icon(Icons.location_on, color: AppTheme.secondaryColor1, size: Responsive.w(context, 16)),
              SizedBox(width: Responsive.w(context, 8)),
              Text(
                "${_assignedLanes.length} ACTIVE LANES  •  ${_currentWasteType.toUpperCase()}",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textColor.withValues(alpha: 0.6), letterSpacing: 1.0, fontWeight: FontWeight.w700, fontSize: Responsive.sp(context, 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLaneList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24), vertical: Responsive.h(context, 8)),
      itemCount: _assignedLanes.length + 1, // +1 for the "End of list" text
      itemBuilder: (context, index) {
        // Show "End of list" at the very bottom
        if (index == _assignedLanes.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 32)),
            child: Center(
              child: Text(
                "END OF ASSIGNED LIST\n• • •",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textColor.withValues(alpha: 0.3), letterSpacing: 2.0, fontWeight: FontWeight.bold, height: 1.5),
              ),
            ),
          );
        }

        final laneName = _assignedLanes[index];
        // For the prototype, we treat the FIRST item (index 0) as the "Current" active lane
        final bool isCurrentActive = index == 0;

        return _buildLaneCard(context, laneName, isCurrentActive);
      },
    );
  }

  Widget _buildLaneCard(BuildContext context, String laneName, bool isCurrent) {
    final int fakeHouseCount = 15 + (laneName.length % 20);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LaneHousesPage(laneName: laneName, totalHouses: fakeHouseCount),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: Responsive.h(context, 16)),
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.r(context, 24)),
          border: Border.all(color: isCurrent ? AppTheme.accentColor : Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            // Left Icon Circle
            Container(
              width: Responsive.w(context, 48),
              height: Responsive.w(context, 48),
              decoration: BoxDecoration(color: isCurrent ? AppTheme.accentColor : AppTheme.primaryBackground, shape: BoxShape.circle),
              child: Icon(isCurrent ? Icons.my_location_rounded : Icons.location_on_rounded, color: isCurrent ? AppTheme.secondaryColor2 : AppTheme.accentColor, size: Responsive.w(context, 20)),
            ),
            SizedBox(width: Responsive.w(context, 16)),

            // Right Text Data
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isCurrent) ...[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 8), vertical: Responsive.h(context, 2)),
                          decoration: BoxDecoration(color: AppTheme.secondaryColor1, borderRadius: BorderRadius.circular(Responsive.r(context, 8))),
                          child: Text(
                            "CURRENT",
                            style: TextStyle(color: Colors.white, fontSize: Responsive.sp(context, 10), fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: Responsive.w(context, 8)),
                      ],
                      Text(
                        _currentSector.toUpperCase(),
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppTheme.secondaryColor1.withValues(alpha: 0.8), fontWeight: FontWeight.w700, letterSpacing: 0.5, fontSize: Responsive.sp(context, 11)),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(context, 4)),
                  Text(
                    laneName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textColor, fontWeight: FontWeight.w700, fontSize: Responsive.sp(context, 20)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        "No routes assigned for\nyour truck today.",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textColor.withValues(alpha: 0.5)),
      ),
    );
  }
}
