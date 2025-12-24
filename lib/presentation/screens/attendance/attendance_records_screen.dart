import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../state/providers/attendance_provider.dart';
import '../../../../data/models/attendance_model.dart';
// import 'package:file_picker/file_picker.dart'; // For real export

class AttendanceRecordsScreen extends StatefulWidget {
  const AttendanceRecordsScreen({super.key});

  @override
  State<AttendanceRecordsScreen> createState() => _AttendanceRecordsScreenState();
}

class _AttendanceRecordsScreenState extends State<AttendanceRecordsScreen> {
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<AttendanceProvider>().getAttendanceHistory(
      _dateRange.start,
      _dateRange.end,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting to Excel...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          const Divider(),
          _buildStats(),
          const Divider(),
          Expanded(
            child: _buildAttendanceTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: _dateRange,
                );
                if (picked != null) {
                  setState(() => _dateRange = picked);
                  _loadData();
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date Range',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.date_range),
                ),
                child: Text(
                  '${DateFormat('dd/MM').format(_dateRange.start)} - ${DateFormat('dd/MM').format(_dateRange.end)}',
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Filter Button stub
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
               showDialog(context: context, builder: (c) => const AlertDialog(title: Text('Filters'), content: Text('Department, Employee filters here')));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, _) {
        final total = provider.history.length;
        // Mock stats logic
        final present = provider.history.where((x) => x.status == 'Present').length;
        final late = 0; // Need 'late' flag in logic/model

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem('Total', '$total', Colors.blue),
              _StatItem('Present', '$present', Colors.green),
              _StatItem('Late', '$late', Colors.orange),
              _StatItem('Absent', '${total - present}', Colors.red),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttendanceTable() {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (provider.history.isEmpty) {
          return const Center(child: Text('No records found'));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
             child: DataTable(
              columns: const [
                DataColumn(label: Text('Employee')), // No name in model yet, assuming user view
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('In')),
                DataColumn(label: Text('Out')),
                DataColumn(label: Text('Hours')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Action')),
              ],
              rows: provider.history.map((record) {
                return DataRow(cells: [
                  const DataCell(Text('User')), // Placeholder
                  DataCell(Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(record.date ?? record.punchIn!.split('T')[0])))),
                  DataCell(Text(record.punchIn != null ? DateFormat('HH:mm').format(DateTime.parse(record.punchIn!)) : '-')),
                  DataCell(Text(record.punchOut != null ? DateFormat('HH:mm').format(DateTime.parse(record.punchOut!)) : '-')),
                  DataCell(Text(record.totalHours ?? '-')),
                  DataCell(_buildStatusBadge(record.status ?? 'Absent')),
                  DataCell(IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () {})),
                ]);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'Present') color = Colors.green;
    if (status == 'Absent') color = Colors.red;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatItem(this.label, this.value, this.color);

  @override
   Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
