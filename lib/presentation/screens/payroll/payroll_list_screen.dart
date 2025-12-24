import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/payroll_provider.dart';
import '../../../data/models/payroll_models.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class PayrollListScreen extends StatefulWidget {
  const PayrollListScreen({super.key});

  @override
  State<PayrollListScreen> createState() => _PayrollListScreenState();
}

class _PayrollListScreenState extends State<PayrollListScreen> {
  DateTime _selectedDate = DateTime.now();
  
  String get _monthYear => DateFormat('yyyy-MM').format(_selectedDate);

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  void _loadData() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PayrollProvider>().loadPayrollList(_monthYear);
      });
  }

  Future<void> _selectMonth(BuildContext context) async {
    final picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        initialDatePickerMode: DatePickerMode.year, // Simplified, native picker doesn't always support Month/Year only well without custom plugins usually.
    );
    if (picked != null && picked != _selectedDate) {
        setState(() => _selectedDate = picked);
        _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Payroll'),
      ),
      body: Consumer<PayrollProvider>(
        builder: (context, provider, child) {
          return Column(
              children: [
                  // Toolbar
                  Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: Row(
                          children: [
                              OutlinedButton.icon(
                                  onPressed: () => _selectMonth(context), 
                                  icon: const Icon(Icons.calendar_month),
                                  label: Text(DateFormat('MMMM yyyy').format(_selectedDate))
                              ),
                              const Spacer(),
                              ElevatedButton(
                                  onPressed: () => _generatePayroll(context),
                                  child: const Text('Generate Payroll'),
                              )
                          ],
                      ),
                  ),
                  
                  // Summary
                  if (provider.payrollSummary != null)
                      _buildSummary(provider.payrollSummary!),
                      
                  const Divider(height: 1),
                  
                  // List
                  Expanded(
                      child: provider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : provider.payrollList.isEmpty
                              ? _buildEmptyState()
                              : _buildTable(provider.payrollList)
                  ),
              ],
          );
        },
      ),
    );
  }
  
  Widget _buildSummary(PayrollSummary summary) {
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.blue[50],
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                  _summaryItem("Employees", "${summary.totalEmployees}"),
                  _summaryItem("Total Gross", "\$${summary.totalGross.toStringAsFixed(2)}"),
                  _summaryItem("Total Net", "\$${summary.totalNet.toStringAsFixed(2)}"),
              ],
          ),
      );
  }
  
  Widget _summaryItem(String label, String val) {
      return Column(
          children: [
              Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
      );
  }
  
  Widget _buildEmptyState() {
      return Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  Icon(Icons.payment, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text("No payroll records for this month"),
                  const SizedBox(height: 8),
                  const Text("Click 'Generate Payroll' to calculate salaries")
              ],
          ),
      );
  }
  
  Widget _buildTable(List<PayrollEntry> list) {
       return SingleChildScrollView(
         scrollDirection: Axis.vertical,
         child: SingleChildScrollView(
             scrollDirection: Axis.horizontal,
             child: DataTable(
                 columns: const [
                     DataColumn(label: Text('Employee')),
                     DataColumn(label: Text('Dept')),
                     DataColumn(label: Text('Basic')),
                     DataColumn(label: Text('Gross')),
                     DataColumn(label: Text('Net')),
                     DataColumn(label: Text('Status')),
                     DataColumn(label: Text('Actions')),
                 ],
                 rows: list.map((e) {
                     return DataRow(cells: [
                         DataCell(Text(e.employeeName, style: const TextStyle(fontWeight: FontWeight.w500))),
                         DataCell(Text(e.department)),
                         DataCell(Text(e.basicSalary.toStringAsFixed(0))),
                         DataCell(Text(e.grossSalary.toStringAsFixed(0))),
                         DataCell(Text(e.netSalary.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold))),
                         DataCell(_buildStatusChip(e.status)),
                         DataCell(Row(
                             children: [
                                 IconButton(
                                     icon: const Icon(Icons.visibility, color: Colors.blue), 
                                     onPressed: () => context.push('/payslip-view', extra: e.id)
                                 ),
                                 if (e.status != 'Paid')
                                     IconButton(
                                         icon: const Icon(Icons.check_circle, color: Colors.green), 
                                         onPressed: () => _markPaid(context, e.id)
                                     )
                             ],
                         )),
                     ]);
                 }).toList(),
             ),
         ),
       );
  }
  
  Widget _buildStatusChip(String status) {
      Color color = Colors.grey;
      if (status == 'Paid') color = Colors.green;
      if (status == 'Draft') color = Colors.orange;
      
      return Chip(
          label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10)),
          backgroundColor: color,
          padding: EdgeInsets.zero,
      );
  }
  
  void _generatePayroll(BuildContext context) async {
       final confirm = await showDialog<bool>(
           context: context,
           builder: (ctx) => AlertDialog(
               title: const Text("Generate Payroll"),
               content: Text("Are you sure you want to generate payroll for $_monthYear? This may overwrite drafts."),
               actions: [
                   TextButton(onPressed: ()=>Navigator.pop(ctx, false), child: const Text("Cancel")),
                   ElevatedButton(onPressed: ()=>Navigator.pop(ctx, true), child: const Text("Generate")),
               ],
           )
       );
       
       if (confirm == true) {
           await context.read<PayrollProvider>().generatePayroll(_monthYear);
       }
  }

  void _markPaid(BuildContext context, int id) async {
      await context.read<PayrollProvider>().markAsPaid([id], _monthYear);
  }
}
