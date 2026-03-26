import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';

class StatusTimelineStep extends StatelessWidget {
  final String title;
  final String sub;
  final bool isDone;
  final bool showLine;
  final IconData icon;

  const StatusTimelineStep({
    super.key,
    required this.title,
    required this.sub,
    required this.isDone,
    required this.showLine,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDone ? AppTheme.accentColor : Colors.transparent,
                border: isDone ? null : Border.all(color: Colors.grey.shade300, width: 2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isDone ? Colors.white : Colors.grey.shade300, size: 16),
            ),
            if (showLine) 
              Container(width: 2, height: 35, color: const Color(0xFFF3F4F6), margin: const EdgeInsets.symmetric(vertical: 4)),
          ],
        ),
        const SizedBox(width: AppTheme.space16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold, color: isDone ? AppTheme.textColor : Colors.grey
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 13, fontStyle: isDone ? FontStyle.normal : FontStyle.italic, color: Colors.grey
              ),
            ),
          ],
        ),
      ],
    );
  }
}