import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/payroll_provider.dart';
import '../../../data/models/payroll_models.dart';

class SalaryStructuresScreen extends StatefulWidget {
  const SalaryStructuresScreen({super.key});

  @override
  State<SalaryStructuresScreen> createState() => _SalaryStructuresScreenState();
}

class _SalaryStructuresScreenState extends State<SalaryStructuresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PayrollProvider>().loadSalaryStructures();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary Structures'),
        actions: [
            IconButton(icon: const Icon(Icons.add), onPressed: (){
                // Add structure flow
            })
        ],
      ),
      body: Consumer<PayrollProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.structures.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.structures.isEmpty) {
             return const Center(child: Text("No salary structures defined."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.structures.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final structure = provider.structures[index];
              return _buildStructureCard(context, structure);
            },
          );
        },
      ),
    );
  }

  Widget _buildStructureCard(BuildContext context, SalaryStructure structure) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(structure.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Base: \$${structure.basicSalary} | Gross: \$${structure.monthlyGross} | Components: ${structure.totalComponents}'),
        children: [
            Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const Text("Earnings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                        const Divider(),
                        ...structure.earnings.map((e) => _buildComponentRow(e)),
                        const SizedBox(height: 16),
                        const Text("Deductions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red)),
                         const Divider(),
                        ...structure.deductions.map((e) => _buildComponentRow(e)),
                        const SizedBox(height: 16),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                                OutlinedButton(onPressed: (){}, child: const Text("Edit")),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.red),
                                        foregroundColor: Colors.red
                                    ),
                                    onPressed: (){}, 
                                    child: const Text("Delete")
                                ),
                            ],
                        )
                    ],
                ),
            )
        ],
      ),
    );
  }
  
  Widget _buildComponentRow(SalaryComponent c) {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  Text(c.name),
                  Text('\$${c.amount} (${c.type})', style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
          ),
      );
  }
}
