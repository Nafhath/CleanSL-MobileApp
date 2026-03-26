import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this to your pubspec.yaml if you haven't: flutter pub add intl
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/responsive.dart';

class ScheduleCalendar extends StatefulWidget {
  const ScheduleCalendar({super.key});

  @override
  State<ScheduleCalendar> createState() => _ScheduleCalendarState();
}

class _ScheduleCalendarState extends State<ScheduleCalendar> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  // Mock data for scheduled pickups (In a real app, fetch this from the backend)
  // 1 = Organic, 2 = Recyclable, 3 = Non-recyclable
  final Map<int, List<int>> _mockSchedules = {
    4: [1], // 4th: Organic
    5: [1], // 5th: Organic
    10: [2], // 10th: Recyclable
    13: [1], // 13th: Organic
    15: [3], // 15th: Non-recyclable
    17: [2], // 17th: Recyclable
    18: [1], // 18th: Organic
    21: [2], // 21st: Recyclable
    24: [2], // 24th: Recyclable
    25: [1], // 25th: Organic
    28: [2], // 28th: Recyclable
    31: [2], // 31st: Recyclable
  };

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(context, 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HEADER (Month Year & Arrows)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, color: AppTheme.secondaryColor1),
                onPressed: _previousMonth,
              ),
              Text(
                DateFormat('MMMM yyyy').format(_focusedMonth),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, color: AppTheme.secondaryColor1),
                onPressed: _nextMonth,
              ),
            ],
          ),
          SizedBox(height: Responsive.h(context, 16)),

          // WEEKDAYS (S M T W T F S)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
              return SizedBox(
                width: Responsive.w(context, 32),
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(color: Colors.blueGrey.shade300, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: Responsive.h(context, 16)),

          // CALENDAR GRID
          _buildCalendarGrid(),
          
          SizedBox(height: Responsive.h(context, 0)),
          const Divider(color: Color(0xFFF3F4F6), height: 0),
          SizedBox(height: Responsive.h(context, 0)),

          // LEGEND
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem("Organic", AppTheme.accentColor),
              _buildLegendItem("Recyclable", AppTheme.secondaryColor1),
              _buildLegendItem("Non-recyclables", AppTheme.secondaryColor2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    // Determine the number of days in the month and the starting weekday
    int daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    DateTime firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    
    // 1 = Monday, 7 = Sunday. Adjusting so Sunday is 0.
    int firstWeekdayOffset = firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;
    
    // Total cells = empty slots + days in month
    int totalCells = firstWeekdayOffset + daysInMonth;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 7 days a week
        childAspectRatio: 0.85, // Adjusts height of each cell
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        if (index < firstWeekdayOffset) {
          // Empty slots for previous month
          int prevMonthDay = DateTime(_focusedMonth.year, _focusedMonth.month, 0).day - (firstWeekdayOffset - 1 - index);
          return _buildDayCell(prevMonthDay, isCurrentMonth: false);
        } else {
          // Actual days of the focused month
          int day = index - firstWeekdayOffset + 1;
          return _buildDayCell(day, isCurrentMonth: true);
        }
      },
    );
  }

  Widget _buildDayCell(int day, {required bool isCurrentMonth}) {
    bool isSelected = isCurrentMonth && 
                      _selectedDate.day == day && 
                      _selectedDate.month == _focusedMonth.month && 
                      _selectedDate.year == _focusedMonth.year;

    // Check if this day has schedules (only if current month)
    List<int> dots = isCurrentMonth ? (_mockSchedules[day] ?? []) : [];

    return GestureDetector(
      onTap: () {
        if (isCurrentMonth) {
          setState(() {
            _selectedDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
          });
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Day Bubble
          Container(
            width: Responsive.w(context, 32),
            height: Responsive.w(context, 32),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.accentColor.withValues(alpha: 0.2) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: isCurrentMonth 
                      ? (isSelected ? AppTheme.secondaryColor1 : AppTheme.textColor)
                      : Colors.grey.shade300,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Dots Indicator
          if (dots.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: dots.map((type) {
                Color dotColor;
                if (type == 1) {
                  dotColor = AppTheme.accentColor;
                } else if (type == 2) {
                  dotColor = AppTheme.secondaryColor1;
                } else {
                  dotColor = AppTheme.secondaryColor2;
                }
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                );
              }).toList(),
            )
          else
            const SizedBox(height: 4), // Placeholder to keep grid aligned
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 11, color: AppTheme.textColor.withValues(alpha: 0.8), fontWeight: FontWeight.w500)),
      ],
    );
  }
}