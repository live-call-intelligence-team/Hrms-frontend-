import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/shift_provider.dart';
import '../../../data/models/shift_models.dart';

class ShiftRostersScreen extends StatefulWidget {
  const ShiftRostersScreen({super.key});

  @override
  State<ShiftRostersScreen> createState() => _ShiftRostersScreenState();
}

class _ShiftRostersScreenState extends State<ShiftRostersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShiftProvider>().loadRosters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift Rosters'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {
              // Navigate to create roster form
          })
        ],
      ),
      body: Consumer<ShiftProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.rosters.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
           if (provider.rosters.isEmpty) {
             return const Center(child: Text('No rosters found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.rosters.length,
            separatorBuilder: (ctx, i) => const Divider(),
            itemBuilder: (context, index) {
              final roster = provider.rosters[index];
              return ListTile(
                title: Text(roster.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Effective: ${roster.effectiveDate} | Employees: ${roster.employeeCount}'),
                trailing: Chip(
                  label: Text(roster.status),
                  backgroundColor: roster.status == 'Active' ? Colors.green[100] : Colors.grey[200],
                ),
                onTap: () {
                    // Navigate to details/assignment view
                },
              );
            },
          );
        },
      ),
    );
  }
}
