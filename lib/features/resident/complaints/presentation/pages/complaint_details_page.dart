import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../data/complaint_model.dart';
import '../widgets/pending_complaint_view.dart';
import '../widgets/in_progress_complaint_view.dart';
import '../widgets/resolved_complaint_view.dart';
import 'file_complaint_page.dart';

class ComplaintDetailsPage extends StatelessWidget {
  final Complaint complaint;

  const ComplaintDetailsPage({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(child: _buildBodyContent(context)),

      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const FileComplaintPage()));
          },
          backgroundColor: AppTheme.accentColor,
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 36),
        ),
      ),
    );
  }

  // --- APP BAR ---
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: Padding(
        padding: const EdgeInsets.all(AppTheme.space8),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text("Complaint Details", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  // --- ROUTER (The Magic Part) ---
  Widget _buildBodyContent(BuildContext context) {
    switch (complaint.status) {
      case "Pending":
        return PendingComplaintView(complaint: complaint);
      case "In Progress":
        return InProgressComplaintView(complaint: complaint);
      case "Resolved":
        return ResolvedComplaintView(complaint: complaint);
      default:
        return const Center(child: Text("Status Unknown"));
    }
  }
}
