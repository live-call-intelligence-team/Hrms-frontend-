import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/shift_provider.dart';
import '../../../data/models/shift_models.dart';
import 'package:go_router/go_router.dart';

class ShiftsListScreen extends StatefulWidget {
  const ShiftsListScreen({super.key});

  @override
  State<ShiftsListScreen> createState() => _ShiftsListScreenState();
}

class _ShiftsListScreenState extends State<ShiftsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShiftProvider>().loadShifts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Shifts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
               context.push('/shift-form');
            },
          ),
        ],
      ),
      body: Consumer<ShiftProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.shifts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.shifts.isEmpty) {
             return const Center(child: Text('No shifts found. Add a new one!'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.shifts.length,
            itemBuilder: (context, index) {
              final shift = provider.shifts[index];
              return _buildShiftCard(context, shift);
            },
          );
        },
      ),
    );
  }

  Widget _buildShiftCard(BuildContext context, Shift shift) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(shift.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${shift.startTime} - ${shift.endTime}'),
            Text('Break: ${shift.breakDuration} | Total: ${shift.totalHours}'),
            Text('Employees: ${shift.employeeCount ?? 0}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
             IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                context.push('/shift-form', extra: shift);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, shift),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Shift shift) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Shift'),
        content: Text('Are you sure you want to delete ${shift.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<ShiftProvider>().deleteShift(shift.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
