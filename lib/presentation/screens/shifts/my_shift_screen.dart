import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/shift_provider.dart';
import '../../../data/models/shift_models.dart';
import 'package:table_calendar/table_calendar.dart';


class MyShiftScreen extends StatefulWidget {
  const MyShiftScreen({super.key});

  @override
  State<MyShiftScreen> createState() => _MyShiftScreenState();
}

class _MyShiftScreenState extends State<MyShiftScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShiftProvider>().loadUserShifts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shifts'),
        actions: [
            TextButton.icon(
                onPressed: () {
                    Navigator.pushNamed(context, '/shift-change-requests');
                }, 
                icon: const Icon(Icons.swap_horiz, color: Colors.white), 
                label: const Text("Requests", style: TextStyle(color: Colors.white))
            )
        ],
      ),
      body: Consumer<ShiftProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.userShifts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Map shifts to a calendar event structure if needed, or lookup directly
          
          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: (day) {
                  // Find shifts for this day
                   final shifts = provider.userShifts.where((s) {
                       // Basic parsing match. Improve with better date objects.
                       return s.date == day.toString().substring(0, 10);
                   }).toList();
                   return shifts;
                },
                calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildShiftListForDay(provider.userShifts, _selectedDay),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShiftListForDay(List<UserShift> allShifts, DateTime? date) {
      if (date == null) return const SizedBox();
      final dateStr = date.toString().substring(0, 10);
      final shifts = allShifts.where((s) => s.date == dateStr).toList();
      
      if (shifts.isEmpty) {
          return const Center(child: Text("No shifts scheduled for this day"));
      }

      return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: shifts.length,
          itemBuilder: (ctx, idx) {
              final shiftItem = shifts[idx];
              return Card(
                  color: Colors.blue[50],
                  child: ListTile(
                      leading: const Icon(Icons.access_time_filled, color: Colors.blue),
                      title: Text(shiftItem.shift?.name ?? shiftItem.type, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: shiftItem.shift != null 
                        ? Text("${shiftItem.shift!.startTime} - ${shiftItem.shift!.endTime}")
                        : null,
                      trailing: IconButton(
                          icon: const Icon(Icons.edit_calendar),
                          onPressed: () {
                              _showRequestChangeDialog(context, shiftItem);
                          },
                          tooltip: 'Request Change',
                      ),
                  ),
              );
          },
      );
  }

  void _showRequestChangeDialog(BuildContext context, UserShift userShift) {
       // Navigate to change request screen with pre-filled details or simple dialog
       // For this task, let's just push to the request screen passing arguments if implemented, 
       // but typically screen 12 acts as both list and form or has tabs. 
       // Let's assume we push to a form or use the request screen.
       // Here I'll just show a placeholder since specific "Request Form" logic is part of Screen 12 description or implied.
       
       // Actually Screen 12 says: "Employee: Request form...". So maybe Screen 12 handles the form.
       // Let's navigate there.
       Navigator.pushNamed(context, '/shift-change-requests', arguments: userShift); 
  }
}
