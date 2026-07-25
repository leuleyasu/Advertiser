import 'package:flutter/material.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/utils/format_utils.dart';

class CampaignScheduleStep extends StatelessWidget {
  final DateTimeRange? dateRange;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<int> selectedDays;
  final VoidCallback onSelectDateRange;
  final VoidCallback onSelectStartTime;
  final VoidCallback onSelectEndTime;
  final ValueChanged<int> onToggleDay;

  const CampaignScheduleStep({
    super.key,
    required this.dateRange,
    required this.startTime,
    required this.endTime,
    required this.selectedDays,
    required this.onSelectDateRange,
    required this.onSelectStartTime,
    required this.onSelectEndTime,
    required this.onToggleDay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Display Scheduling',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Date Range Picker Button
        InkWell(
          onTap: onSelectDateRange,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.date_range, color: primaryColor),
                const SizedBox(width: 12),
                Text(
                  FormatUtils.formatDateRange(dateRange),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: Colors.white60),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Time window selection
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text('Start Time', style: TextStyle(color: Colors.white60, fontSize: 12)),
                subtitle: Text(
                  startTime.format(context),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.access_time, color: primaryColor),
                onTap: onSelectStartTime,
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text('End Time', style: TextStyle(color: Colors.white60, fontSize: 12)),
                subtitle: Text(
                  endTime.format(context),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.access_time, color: primaryColor),
                onTap: onSelectEndTime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Weekdays selection
        const Text('Days of Week', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final dayInt = index + 1;
            final dayLabel = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index];
            final isSelected = selectedDays.contains(dayInt);
            return InkWell(
              onTap: () => onToggleDay(dayInt),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.white.withOpacity(0.04),
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? primaryColor : Colors.white10),
                ),
                child: Center(
                  child: Text(
                    dayLabel,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
