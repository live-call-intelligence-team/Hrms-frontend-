import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../state/providers/holiday_provider.dart';
import '../../../../data/models/holiday_model.dart';
// import 'package:go_router/go_router.dart';

class HolidaysScreen extends StatefulWidget {
  const HolidaysScreen({super.key});

  @override
  State<HolidaysScreen> createState() => _HolidaysScreenState();
}

class _HolidaysScreenState extends State<HolidaysScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final bool _isAdmin = true; // TODO: Get from AuthProvider
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HolidayProvider>().loadHolidays();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Holidays'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month), text: 'Calendar'),
            Tab(icon: Icon(Icons.list), text: 'List'),
          ],
        ),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddHolidayDialog(context),
            ),
        ],
      ),
      body: Consumer<HolidayProvider>(
        builder: (context, provider, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildCalendarView(provider),
              _buildListView(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendarView(HolidayProvider provider) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2023, 1, 1),
          lastDay: DateTime.utc(2025, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
               final dateStr = DateFormat('yyyy-MM-dd').format(date);
               final holiday = provider.holidays.firstWhere(
                 (h) => DateFormat('yyyy-MM-dd').format(h.date) == dateStr, 
                 orElse: () => HolidayModel(name: '', date: date, type: ''),
               );
               
               if (holiday.name.isNotEmpty) {
                 return Container(
                   decoration: const BoxDecoration(
                     color: Colors.blue,
                     shape: BoxShape.circle,
                   ),
                   width: 7,
                   height: 7,
                   margin: const EdgeInsets.symmetric(horizontal: 1.5),
                 );
               }
               return null;
            },
          ),
          onDaySelected: (selectedDay, focusedDay) {
            final dateStr = DateFormat('yyyy-MM-dd').format(selectedDay);
            final holiday = provider.holidays.firstWhere(
               (h) => DateFormat('yyyy-MM-dd').format(h.date) == dateStr, 
               orElse: () => HolidayModel(name: '', date: selectedDay, type: ''),
             );
            
            if (holiday.name.isNotEmpty) {
               showDialog(
                 context: context,
                 builder: (c) => AlertDialog(
                   title: Text(holiday.name),
                   content: Text('Date: $dateStr\nType: ${holiday.type}'),
                   actions: [TextButton(onPressed: ()=>Navigator.pop(c), child: const Text('Close'))],
                 ),
               );
            }
          },
        ),
        const Expanded(
          child: Center(
            child: Text('Tap on a marked day to see details'),
          ),
        ),
      ],
    );
  }

  Widget _buildListView(HolidayProvider provider) {
    if (provider.holidays.isEmpty) {
      return const Center(child: Text('No holidays found'));
    }
    
    // Sort by date
    final holidays = List<HolidayModel>.from(provider.holidays);
    holidays.sort((a, b) => a.date.compareTo(b.date));

    return ListView.builder(
      itemCount: holidays.length,
      itemBuilder: (context, index) {
        final holiday = holidays[index];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              DateFormat('MMM\ndd').format(holiday.date),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          title: Text(holiday.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(holiday.type),
          trailing: _isAdmin ? IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
               // Confirm delete
               // provider.deleteHoliday(holiday.id!);
            },
          ) : null,
        );
      },
    );
  }

  void _showAddHolidayDialog(BuildContext context) {
    final _nameController = TextEditingController();
    final _typeController = TextEditingController(text: 'Public');
    DateTime _date = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Holiday'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
                   TextField(controller: _typeController, decoration: const InputDecoration(labelText: 'Type')),
                   const SizedBox(height: 16),
                   ListTile(
                     title: Text('Date: ${DateFormat('yyyy-MM-dd').format(_date)}'),
                     trailing: const Icon(Icons.calendar_today),
                     onTap: () async {
                       final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2023), lastDate: DateTime(2025));
                       if (d != null) setState(() => _date = d);
                     },
                   ),
                ],
              ),
              actions: [
                TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    final holiday = HolidayModel(
                      name: _nameController.text,
                      date: _date,
                      type: _typeController.text,
                    );
                    context.read<HolidayProvider>().addHoliday(holiday);
                    Navigator.pop(context);
                  }, 
                  child: const Text('Add'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
