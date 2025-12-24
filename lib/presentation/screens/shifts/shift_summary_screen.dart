import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/shift_provider.dart';
import '../../../data/models/shift_models.dart';
import 'package:fl_chart/fl_chart.dart';

class ShiftSummaryScreen extends StatefulWidget {
  const ShiftSummaryScreen({super.key});

  @override
  State<ShiftSummaryScreen> createState() => _ShiftSummaryScreenState();
}

class _ShiftSummaryScreenState extends State<ShiftSummaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShiftProvider>().loadSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift Analytics'),
        actions: [
          IconButton(onPressed: () {
              // Export action
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading Report...')));
          }, icon: const Icon(Icons.download))
        ],
      ),
      body: Consumer<ShiftProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.summary == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final summary = provider.summary;
          if (summary == null) {
              return const Center(child: Text("No data available"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    // Summary Cards
                    Row(
                        children: [
                            Expanded(child: _buildInfoCard('Total Shifts', summary.totalShifts.toString(), Colors.blue)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildInfoCard('Total Employees', summary.totalEmployees.toString(), Colors.green)),
                        ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Chart
                    const Text('Shift Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                        height: 200,
                        child: PieChart(
                            PieChartData(
                                sections: summary.distribution.map((d) {
                                    return PieChartSectionData(
                                        value: d.count.toDouble(),
                                        title: '${d.count}',
                                        color: Colors.primaries[summary.distribution.indexOf(d) % Colors.primaries.length],
                                        radius: 50,
                                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                                    );
                                }).toList(),
                            )
                        ),
                    ),
                    
                     const SizedBox(height: 24),
                     // Table
                     const Text('Detailed Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                     const SizedBox(height: 16),
                     SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                            columns: const [
                                DataColumn(label: Text('Shift Name')),
                                DataColumn(label: Text('Count')),
                                DataColumn(label: Text('Avg Hours')),
                                DataColumn(label: Text('Coverage')),
                            ],
                            rows: summary.report.map((item) {
                                return DataRow(cells: [
                                    DataCell(Text(item.shiftName)),
                                    DataCell(Text(item.employeeCount.toString())),
                                    DataCell(Text(item.avgHours)),
                                    DataCell(Text('${item.coveragePercent}%')),
                                ]);
                            }).toList(),
                        ),
                     ),
                ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color color) {
    return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                children: [
                    Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                    const SizedBox(height: 4),
                    Text(title, style: const TextStyle(color: Colors.grey)),
                ],
            ),
        ),
    );
  }
}
