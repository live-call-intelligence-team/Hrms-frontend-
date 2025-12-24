import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/payroll_provider.dart';
import '../../../data/models/payroll_models.dart';

class PayslipScreen extends StatefulWidget {
  final int payrollId;

  const PayslipScreen({super.key, required this.payrollId});

  @override
  State<PayslipScreen> createState() => _PayslipScreenState();
}

class _PayslipScreenState extends State<PayslipScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PayrollProvider>().loadPayslip(widget.payrollId);
    });
  }

  @override
  void dispose() {
     // Optional: clear current payslip on exit if you want to avoid flash on next load
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payslip'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
                // Print functionality placeholder
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Print initiated...')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sharing...')));
            },
          )
        ],
      ),
      body: Consumer<PayrollProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.currentPayslip == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final payslip = provider.currentPayslip;
          if (payslip == null) {
              return const Center(child: Text("Payslip not found"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 4,
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                          // Header
                          Center(
                              child: Column(
                                  children: [
                                      Text(payslip.companyInfo.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                      Text(payslip.companyInfo.address, style: const TextStyle(color: Colors.grey)),
                                      const SizedBox(height: 16),
                                      Text("PAYSLIP FOR ${payslip.monthYear}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                                  ],
                              ),
                          ),
                          const Divider(height: 32, thickness: 2),
                          
                          // Employee Info
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Expanded(child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                          _infoRow("Employee Name", payslip.employeeInfo.name),
                                          _infoRow("Employee ID", payslip.employeeInfo.employeeId),
                                          _infoRow("Designation", payslip.employeeInfo.designation),
                                      ],
                                  )),
                                  Expanded(child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                          _infoRow("Department", payslip.employeeInfo.department),
                                          _infoRow("Joining Date", payslip.employeeInfo.joiningDate),
                                          _infoRow("Paid Days", "30"), // dynamic if avail
                                      ],
                                  )),
                              ],
                          ),
                          
                           const Divider(height: 32),
                           
                           // Salary Table
                           Table(
                               border: TableBorder.all(color: Colors.grey[300]!),
                               children: [
                                   // Header
                                   TableRow(
                                       decoration: BoxDecoration(color: Colors.grey[100]),
                                       children: const [
                                           Padding(padding: EdgeInsets.all(8), child: Text("EARNINGS", style: TextStyle(fontWeight: FontWeight.bold))),
                                           Padding(padding: EdgeInsets.all(8), child: Text("AMOUNT", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                                           Padding(padding: EdgeInsets.all(8), child: Text("DEDUCTIONS", style: TextStyle(fontWeight: FontWeight.bold))),
                                           Padding(padding: EdgeInsets.all(8), child: Text("AMOUNT", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                                       ]
                                   ),
                                   // Rows (Assuming earnings and deductions list match or we pad)
                                    ..._buildSalaryRows(payslip),
                                    
                                   // Totals
                                   TableRow(
                                        decoration: BoxDecoration(color: Colors.grey[50]),
                                       children: [
                                           const Padding(padding: EdgeInsets.all(8), child: Text("Total Earnings", style: TextStyle(fontWeight: FontWeight.bold))),
                                           Padding(padding: const EdgeInsets.all(8), child: Text(payslip.totalEarnings.toStringAsFixed(2), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
                                           const Padding(padding: EdgeInsets.all(8), child: Text("Total Deductions", style: TextStyle(fontWeight: FontWeight.bold))),
                                           Padding(padding: const EdgeInsets.all(8), child: Text(payslip.totalDeductions.toStringAsFixed(2), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
                                       ]
                                   )
                               ],
                           ),
                           
                           const SizedBox(height: 32),
                           
                           // Net Pay
                           Container(
                               padding: const EdgeInsets.all(16),
                               decoration: BoxDecoration(
                                   color: Colors.blue[50],
                                   border: Border.all(color: Colors.blue[100]!),
                                   borderRadius: BorderRadius.circular(8)
                               ),
                               child: Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: [
                                       const Text("NET PAY", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                                       Text("\$${payslip.netSalary.toStringAsFixed(2)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                                   ],
                               ),
                           ),
                           
                            const SizedBox(height: 32),
                            const Text("Authorized Signatory", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                  ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _infoRow(String label, String value) {
      return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
              children: [
                  SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12))),
                  Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
              ],
          ),
      );
  }
  
  List<TableRow> _buildSalaryRows(Payslip p) {
      List<TableRow> rows = [];
      int count = p.earnings.length > p.deductions.length ? p.earnings.length : p.deductions.length;
      
      for(int i=0; i<count; i++) {
          final earn = i < p.earnings.length ? p.earnings[i] : null;
          final ded = i < p.deductions.length ? p.deductions[i] : null;
          
          rows.add(TableRow(
              children: [
                  Padding(padding: const EdgeInsets.all(8), child: Text(earn?.name ?? '')),
                  Padding(padding: const EdgeInsets.all(8), child: Text(earn?.amount.toStringAsFixed(2) ?? '', textAlign: TextAlign.right)),
                  Padding(padding: const EdgeInsets.all(8), child: Text(ded?.name ?? '')),
                  Padding(padding: const EdgeInsets.all(8), child: Text(ded?.amount.toStringAsFixed(2) ?? '', textAlign: TextAlign.right)),
              ]
          ));
      }
      return rows;
  }
}
