import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';
import '../../data/complaint_model.dart';
import '../pages/complaint_details_page.dart';

class ComplaintCard extends StatelessWidget {
  final Complaint complaint;

  const ComplaintCard({super.key, required this.complaint});

  void _navigateToDetails(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ComplaintDetailsPage(complaint: complaint)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Container(
        margin: EdgeInsets.only(bottom: Responsive.h(context, 20)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.r(context, 24)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGE SECTION ---
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: complaint.isLocal
                  ? Image.asset(complaint.imagePath, height: Responsive.h(context, 160), width: double.infinity, fit: BoxFit.cover)
                  : Image.network(
                      complaint.imagePath,
                      height: Responsive.h(context, 160),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: Responsive.h(context, 160),
                          color: Colors.grey.shade100,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: Responsive.h(context, 160),
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                      ),
                    ),
            ),

            // --- CONTENT SECTION ---
            Padding(
              padding: EdgeInsets.all(Responsive.w(context, 16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatusBadge(status: complaint.status),
                      Text(
                        "ID: #${complaint.id}",
                        style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(context, 12)),
                  Text(complaint.category, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: Responsive.h(context, 4)),
                  Text(
                    "Submitted on ${complaint.dateSubmitted}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: Responsive.h(context, 8)),
                  Text(
                    complaint.fullDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.4, fontSize: 13),
                  ),
                  SizedBox(height: Responsive.h(context, 16)),

                  // --- FOOTER SECTION ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ComplaintInfoRow(complaint: complaint),
                      ElevatedButton(
                        onPressed: () => _navigateToDetails(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("View Details", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ), // GestureDetector
    );
  }
}

// --- INTERNAL HELPERS ---

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    if (status == "In Progress") {
      bg = Colors.orange.shade50;
      text = Colors.orange.shade700;
    } else if (status == "Resolved") {
      bg = AppTheme.accentColor.withValues(alpha: 0.1);
      text = AppTheme.accentColor;
    } else {
      bg = Colors.grey.shade100;
      text = Colors.grey.shade700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        status,
        style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ComplaintInfoRow extends StatelessWidget {
  final Complaint complaint;
  const _ComplaintInfoRow({required this.complaint});

  @override
  Widget build(BuildContext context) {
    if (complaint.status == "In Progress") {
      return _buildRow(Icons.stars_rounded, complaint.assignedTo ?? "Team Dispatched", Colors.orange);
    } else if (complaint.status == "Resolved") {
      return _buildRow(Icons.check_circle_rounded, "Done ${complaint.completionDate}", AppTheme.accentColor);
    } else {
      return Row(
        children: [
          Icon(Icons.access_time_filled_rounded, color: Colors.grey.shade400, size: 16),
          const SizedBox(width: 4),
          const Text("Awaiting Review", style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      );
    }
  }

  Widget _buildRow(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
