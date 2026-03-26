import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/responsive.dart';
import 'driver_voice_record_page.dart';

class LaneHousesPage extends StatefulWidget {
  final String laneName;
  final int totalHouses;

  const LaneHousesPage({super.key, required this.laneName, required this.totalHouses});

  @override
  State<LaneHousesPage> createState() => _LaneHousesPageState();
}

enum HouseStatus { pending, collected, issue }

class _LaneHousesPageState extends State<LaneHousesPage> {
  // This Map keeps track of each house's status.
  final Map<int, HouseStatus> _houseStatuses = {};

  int get _issueCount => _houseStatuses.values.where((s) => s == HouseStatus.issue).length;

  Future<void> _handleLongPress(int houseNumber) async {
    // 1. Navigate to the Voice page and WAIT for the result
    final bool? issueConfirmed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoiceRecordPage(
          taskId: "mock-task-id-$houseNumber", // ⚠️ TODO: Replace with real collection_tasks.id in Step 4
          laneName: widget.laneName,
          houseNumber: houseNumber,
        ),
      ),
    );

    // 2. If the driver clicked 'Confirm & Submit', it returns true. 
    // ONLY THEN do we turn the house red.
    if (issueConfirmed == true) {
      setState(() {
        _houseStatuses[houseNumber] = HouseStatus.issue;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Issue reported for House $houseNumber"),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleTap(int houseNumber) {
    setState(() {
      final current = _houseStatuses[houseNumber] ?? HouseStatus.pending;
      if (current == HouseStatus.pending) {
        _houseStatuses[houseNumber] = HouseStatus.collected;
      } else if (current == HouseStatus.collected) {
        _houseStatuses[houseNumber] = HouseStatus.pending;
      } else if (current == HouseStatus.issue) {
        _houseStatuses[houseNumber] = HouseStatus.pending;
      }
    });
  }

  void _handleDoubleTap(int houseNumber) {
    setState(() {
      final current = _houseStatuses[houseNumber] ?? HouseStatus.pending;
      if (current == HouseStatus.issue) {
        _houseStatuses[houseNumber] = HouseStatus.pending;
      } else {
        _houseStatuses[houseNumber] = HouseStatus.issue;
      }
    });
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
            SizedBox(height: Responsive.h(context, 24)),

            // The Grid of Houses
            Expanded(child: _buildHouseGrid(context)),
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
            widget.laneName,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppTheme.textColor, fontSize: Responsive.sp(context, 32)),
          ),
          SizedBox(height: Responsive.h(context, 8)),
          Text(
            "${widget.totalHouses} Houses  •  $_issueCount Issues",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textColor.withValues(alpha: 0.7), fontSize: Responsive.sp(context, 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildHouseGrid(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(context, 24), // left
        Responsive.h(context, 0), // top
        Responsive.w(context, 24), // right
        Responsive.h(context, 48), // bottom
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 columns exactly like your mockup
        crossAxisSpacing: Responsive.w(context, 16),
        mainAxisSpacing: Responsive.h(context, 16),
        childAspectRatio: 1.0, // Perfect squares
      ),
      itemCount: widget.totalHouses,
      itemBuilder: (context, index) {
        final int houseNumber = index + 1;
        final status = _houseStatuses[houseNumber] ?? HouseStatus.pending;

        Color bgColor;
        Color textColor = Colors.white;

        if (status == HouseStatus.collected) {
          bgColor = AppTheme.accentColor; // Green
        } else if (status == HouseStatus.issue) {
          bgColor = Colors.red.shade500; // Red
        } else {
          bgColor = Colors.white; // Pending is white
          textColor = AppTheme.secondaryColor1;
        }

        return GestureDetector(
          onTap: () => _handleTap(houseNumber),
          onDoubleTap: () => _handleDoubleTap(houseNumber),
          onLongPress: () => _handleLongPress(houseNumber),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(Responsive.r(context, 20)),
              boxShadow: [BoxShadow(color: bgColor.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 4))],
              border: status == HouseStatus.pending 
                  ? Border.all(color: AppTheme.secondaryColor1.withValues(alpha: 0.1), width: 1.5) 
                  : null,
            ),
            child: Center(
              child: Text(
                "$houseNumber",
                style: Theme.of(context).textTheme.displaySmall?.copyWith(color: textColor, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        );
      },
    );
  }
}
