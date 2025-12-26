import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/payroll_provider.dart';

class MyPayslipsScreen extends StatefulWidget {
  const MyPayslipsScreen({super.key});

  @override
  State<MyPayslipsScreen> createState() => _MyPayslipsScreenState();
}

class _MyPayslipsScreenState extends State<MyPayslipsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PayrollProvider>().loadMyPayslips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Payslips')),
      body: Consumer<PayrollProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.myPayslipHistory.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Stats
                if (provider.myStats != null)
                  _buildStatsCard(provider.myStats!),

                const SizedBox(height: 24),
                const Text(
                  "Payslip History",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                if (provider.myPayslipHistory.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text("No payslips generated yet"),
                    ),
                  ),

                ...provider.myPayslipHistory.map(
                  (p) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.description,
                          color: Colors.blue,
                        ),
                      ),
                      title: Text(
                        p.month,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Net Pay: \$${p.netSalary.toStringAsFixed(2)}",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () {
                          // View/Downlaod logic. For now view payslip screen
                          Navigator.pushNamed(
                            context,
                            '/payslip-view',
                            arguments: p.id,
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/payslip-view',
                          arguments: p.id,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(dynamic stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Total Earned (YTD)",
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              "\$${stats.totalEarnedYear.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      "Avg Monthly",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      "\$${stats.avgMonthly.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 30, color: Colors.white24),
                Column(
                  children: [
                    const Text(
                      "Highest Month",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      "\$${stats.highestMonth.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
