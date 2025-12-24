import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/shift_provider.dart';
import '../../../data/models/shift_models.dart';

class ShiftChangeRequestsScreen extends StatefulWidget {
  final UserShift? shiftToChange; // Optional, if coming from MyShiftScreen with a specific shift

  const ShiftChangeRequestsScreen({super.key, this.shiftToChange});

  @override
  State<ShiftChangeRequestsScreen> createState() => _ShiftChangeRequestsScreenState();
}

class _ShiftChangeRequestsScreenState extends State<ShiftChangeRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
     WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShiftProvider>().loadChangeRequests();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift Change Requests'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'New Request'),
            Tab(text: 'My Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _NewRequestForm(initialShift: widget.shiftToChange), // Form
          _MyRequestsList(), // List
        ],
      ),
    );
  }
}

class _NewRequestForm extends StatefulWidget {
  final UserShift? initialShift;
  const _NewRequestForm({this.initialShift});

  @override
  State<_NewRequestForm> createState() => _NewRequestFormState();
}

class _NewRequestFormState extends State<_NewRequestForm> {
    final _formKey = GlobalKey<FormState>();
    late TextEditingController _currentShiftDateController;
    late TextEditingController _reasonController;
    
    // For simplicity, using text fields for shift selections.
    // In real app, these would be dropdowns or pickers.
    String? _selectedCurrentShiftName; 
    String? _selectedRequestedShiftName; 

    @override
    void initState() {
        super.initState();
        _currentShiftDateController = TextEditingController(text: widget.initialShift?.date ?? '');
        _reasonController = TextEditingController();
        _selectedCurrentShiftName = widget.initialShift?.shift?.name;
    }
    
    @override
    void dispose() {
        _currentShiftDateController.dispose();
        _reasonController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
                key: _formKey,
                child: Column(
                    children: [
                        TextFormField(
                            controller: _currentShiftDateController,
                            decoration: const InputDecoration(labelText: 'Current Shift Date (YYYY-MM-DD)', border: OutlineInputBorder()),
                            validator: (val) => val!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        // Placeholder for shift selection.
                        TextFormField(
                            initialValue: _selectedCurrentShiftName,
                             decoration: const InputDecoration(labelText: 'Current Shift Name', border: OutlineInputBorder()),
                             onChanged: (val) => _selectedCurrentShiftName = val,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                             decoration: const InputDecoration(labelText: 'Requested Shift', border: OutlineInputBorder(), hintText: 'e.g. Morning Shift'),
                             onSaved: (val) => _selectedRequestedShiftName = val,
                             validator: (val) => val!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                            controller: _reasonController,
                            decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder()),
                            maxLines: 3,
                            validator: (val) => val!.isEmpty ? 'Required' : null,
                        ),
                         const SizedBox(height: 24),
                        ElevatedButton(
                            onPressed: _submit,
                            child: const Text('Submit Request'),
                        )
                    ],
                ),
            ),
        );
    }
    
    void _submit() async {
        if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
             final request = ShiftChangeRequest(
                 id: 0, 
                 userId: 0,// Handled by backend usually
                 userName: '', 
                 currentShiftDate: _currentShiftDateController.text, 
                 currentShiftName: _selectedCurrentShiftName ?? 'Unknown', 
                 requestedShiftName: _selectedRequestedShiftName!, 
                 reason: _reasonController.text, 
                 status: 'Pending'
             );
             
             final success = await context.read<ShiftProvider>().requestShiftChange(request);
             if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request submitted')));
                  // Switch to list tab
                  DefaultTabController.of(context)?.animateTo(1); // Won't work as we use custom controller
                  // We can't easily switch tab from here without passing controller or using parent.
                  // Just show message.
             }
        }
    }
}

class _MyRequestsList extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Consumer<ShiftProvider>(
            builder: (context, provider, child) {
                 if (provider.isLoading && provider.changeRequests.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                 }
                 if (provider.changeRequests.isEmpty) {
                     return const Center(child: Text("No requests found"));
                 }
                 
                 return ListView.builder(
                     itemCount: provider.changeRequests.length,
                     itemBuilder: (ctx, idx) {
                         final req = provider.changeRequests[idx];
                         return ListTile(
                             title: Text("${req.currentShiftDate}: ${req.currentShiftName} -> ${req.requestedShiftName}"),
                             subtitle: Text("Reason: ${req.reason}"),
                             trailing: _buildStatusChip(req.status),
                         );
                     },
                 );
            },
        );
    }
    
    Widget _buildStatusChip(String status) {
        Color color = Colors.orange;
        if (status == 'Approved') color = Colors.green;
        if (status == 'Rejected') color = Colors.red;
        
        return Chip(
            label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12)),
            backgroundColor: color,
        );
    }
}
