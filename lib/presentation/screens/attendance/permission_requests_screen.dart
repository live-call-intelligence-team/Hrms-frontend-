import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../state/providers/permission_provider.dart';
import '../../../../data/models/permission_model.dart';

class PermissionRequestsScreen extends StatefulWidget {
  const PermissionRequestsScreen({super.key});

  @override
  State<PermissionRequestsScreen> createState() => _PermissionRequestsScreenState();
}

class _PermissionRequestsScreenState extends State<PermissionRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final bool _isManager = true; // TODO: Get from AuthProvider
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PermissionProvider>().loadPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Requests'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Requests'),
            Tab(text: 'Apply New'),
          ],
        ),
      ),
      body: Consumer<PermissionProvider>(
        builder: (context, provider, _) {
          return TabBarView(
             controller: _tabController,
             children: [
               _buildRequestsList(provider),
               _buildApplyForm(provider),
             ],
          );
        },
      ),
    );
  }

  Widget _buildRequestsList(PermissionProvider provider) {
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.permissions.isEmpty) return const Center(child: Text('No permissions requests'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.permissions.length,
      itemBuilder: (context, index) {
        final perm = provider.permissions[index];
        return Card(
           child: ListTile(
             title: Text('${perm.type} - ${DateFormat('dd MMM').format(perm.date)}'),
             subtitle: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text('${perm.startTime.format(context)} - ${perm.endTime.format(context)} (${perm.durationString})'),
                 if (perm.reason.isNotEmpty) Text('Reason: ${perm.reason}', style: const TextStyle(fontStyle: FontStyle.italic)),
                 if (_isManager && perm.employeeName.isNotEmpty) Text('User: ${perm.employeeName}'),
               ],
             ),
             trailing: _buildStatusAction(perm, provider),
           ),
        );
      },
    );
  }

  Widget _buildStatusAction(PermissionModel perm, PermissionProvider provider) {
    if (perm.status == 'Pending' && _isManager) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            onPressed: () => provider.updateStatus(perm.id!, 'Approved'),
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            onPressed: () => provider.updateStatus(perm.id!, 'Rejected'),
          ),
        ],
      );
    }
    
    Color color = Colors.orange;
    if (perm.status == 'Approved') color = Colors.green;
    if (perm.status == 'Rejected') color = Colors.red;
    
    return Text(perm.status, style: TextStyle(color: color, fontWeight: FontWeight.bold));
  }
  
  // Apply Form State
  final _formKey = GlobalKey<FormState>();
  DateTime? _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final _reasonController = TextEditingController();
  String _type = 'Personal Work';
  
  Widget _buildApplyForm(PermissionProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
              items: ['Personal Work', 'Official Work', 'Medical', 'Late Arrival', 'Early Exit']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _type = val!),
            ),
             const SizedBox(height: 16),
             InkWell(
               onTap: () async {
                 final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30)));
                 if (d != null) setState(()=>_date = d);
               },
               child: InputDecorator(
                 decoration: const InputDecoration(labelText: 'Date', border: OutlineInputBorder()),
                 child: Text(_date != null ? DateFormat('dd/MM/yyyy').format(_date!) : 'Select Date'),
               ),
             ),
             const SizedBox(height: 16),
             Row(
               children: [
                 Expanded(
                   child: InkWell(
                     onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (t != null) setState(()=>_startTime = t);
                     },
                     child: InputDecorator(
                       decoration: const InputDecoration(labelText: 'Start Time', border: OutlineInputBorder()),
                       child: Text(_startTime?.format(context) ?? 'Select'),
                     ),
                   ),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: InkWell(
                     onTap: () async {
                        final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (t != null) setState(()=>_endTime = t);
                     },
                     child: InputDecorator(
                       decoration: const InputDecoration(labelText: 'End Time', border: OutlineInputBorder()),
                       child: Text(_endTime?.format(context) ?? 'Select'),
                     ),
                   ),
                 ),
               ],
             ),
             const SizedBox(height: 16),
             TextFormField(
               controller: _reasonController,
               decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder()),
               maxLines: 2,
               validator: (v) => v!.isEmpty ? 'Required' : null,
             ),
             const SizedBox(height: 24),
             SizedBox(
               width: double.infinity,
               height: 50,
               child: ElevatedButton(
                 onPressed: () async {
                   if (_formKey.currentState!.validate() && _date != null && _startTime != null && _endTime != null) {
                     final perm = PermissionModel(
                       date: _date!,
                       startTime: _startTime!,
                       endTime: _endTime!,
                       reason: _reasonController.text,
                       type: _type,
                     );
                     
                     final success = await provider.applyPermission(perm);
                     if (success) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Applied Successfully')));
                       _tabController.animateTo(0); // Go to list
                     }
                   } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                   }
                 },
                 child: provider.isLoading ? const CircularProgressIndicator() : const Text('Submit'),
               ),
             ),
          ],
        ),
      ),
    );
  }
}
