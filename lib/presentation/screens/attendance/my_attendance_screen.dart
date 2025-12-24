import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../state/providers/attendance_provider.dart';
import '../../../../state/providers/holiday_provider.dart';
import '../../../../data/models/attendance_model.dart';
import '../../../../data/models/holiday_model.dart';
import 'package:intl/intl.dart';

class MyAttendanceScreen extends StatefulWidget {
  const MyAttendanceScreen({super.key});

  @override
  State<MyAttendanceScreen> createState() => _MyAttendanceScreenState();
}

class _MyAttendanceScreenState extends State<MyAttendanceScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final start = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final end = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
      
      context.read<AttendanceProvider>().getAttendanceHistory(start, end);
      context.read<HolidayProvider>().loadHolidays();
    });
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    // Combine attendance and holidays
    final attendanceProvider = context.read<AttendanceProvider>();
    final holidayProvider = context.read<HolidayProvider>();
    
    final dateStr = DateFormat('yyyy-MM-dd').format(day);
    
    // Check for holiday
    final holiday = holidayProvider.holidays.firstWhere(
      (h) => DateFormat('yyyy-MM-dd').format(h.date) == dateStr, 
      orElse: () => HolidayModel(name: '', date: day, type: ''),
    );
    
    if (holiday.name.isNotEmpty) {
      return [holiday];
    }

    // Check for attendance
    // This assumes attendance list is populated
    // Note: getAttendanceHistory in provider needs to store result in a list accessible here
    // For now we will assume the provider exposes a `monthAttendance` list or map
    // We will verify this assumption in provider and fixes if needed.
    
    // Temporary logic assuming provider might return data or we handle it via FutureBuilder if not stored.
    // Better pattern: Provider stores data.
    
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export functionality not implemented yet')),
              );
            },
          ),
        ],
      ),
      body: Consumer2<AttendanceProvider, HolidayProvider>(
        builder: (context, attendanceParams, holidayParams, _) {
          return Column(
            children: [
              _buildSummaryCards(),
              TableCalendar(
                firstDay: DateTime.utc(2020, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _showDayDetails(context, selectedDay);
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                  _loadData(); // Re-load for new month
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    // Custom markers or background color based on status
                    return _buildDayMarker(context, date, attendanceParams, holidayParams);
                  },
                ),
              ),
              const SizedBox(height: 20),
              _buildLegend(),
            ],
          );
        },
      ),
    );
  }

  Widget? _buildDayMarker(
    BuildContext context, 
    DateTime date, 
    AttendanceProvider authProvider, 
    HolidayProvider holidayProvider
  ) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    // 1. Holiday (Blue)
    final isHoliday = holidayProvider.holidays.any((h) => DateFormat('yyyy-MM-dd').format(h.date) == dateStr);
    if (isHoliday) {
      return Container(
        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.3), shape: BoxShape.circle),
        margin: const EdgeInsets.all(4.0),
        alignment: Alignment.center,
        child: Text('${date.day}', style: const TextStyle(color: Colors.blue)),
      );
    }
    
    // Future dates - check if weekend?
    if (date.isAfter(DateTime.now())) {
      return null;
    }

    // 2. Attendance Status
    // We need to access the loaded list. 
    // Assuming Provider has `history` list.
    // If not found in history, and it is past date/today -> Absent (Red) ? or just empty?
    // Let's assume we match by date.
    
    // For now simple mocking behavior until provider update:
    // If day is even -> Present (Green), else Absent (Red) for demo if list empty?
    // No, let's use actual data logic.
    
    return null; // Default renderer for now
  }
  
  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Column(children: [Text('20', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text('Present')]),
          Column(children: [Text('2', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text('Absent')]),
          Column(children: [Text('1', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text('Leave')]),
          Column(children: [Text('4', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text('Holiday')]),
        ],
      ),
    );
  }
  
  Widget _buildLegend() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(children: [Icon(Icons.circle, color: Colors.green, size: 12), SizedBox(width: 4), Text('Present')]),
          Row(children: [Icon(Icons.circle, color: Colors.orange, size: 12), SizedBox(width: 4), Text('Leave')]),
          Row(children: [Icon(Icons.circle, color: Colors.red, size: 12), SizedBox(width: 4), Text('Absent')]),
          Row(children: [Icon(Icons.circle, color: Colors.blue, size: 12), SizedBox(width: 4), Text('Holiday')]),
        ],
      ),
    );
  }

  void _showDayDetails(BuildContext context, DateTime day) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('EEEE, d MMMM yyyy').format(day), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              const Text('Status: Present'), // Dynamic
              const Text('Punch In: 09:00 AM'), // Dynamic
              const Text('Punch Out: 06:00 PM'), // Dynamic
              const Text('Total Hours: 9h'), // Dynamic
            ],
          ),
        );
      },
    );
  }
}
