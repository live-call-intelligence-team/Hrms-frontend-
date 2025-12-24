import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../state/providers/leave_provider.dart';
import '../../../../data/models/leave_model.dart';
// import 'package:go_router/go_router.dart'; // Or Navigator

class LeaveRequestsScreen extends StatefulWidget {
  const LeaveRequestsScreen({super.key});

  @override
  State<LeaveRequestsScreen> createState() => _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends State<LeaveRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final bool _isManager = true; // TODO: Get from AuthProvider role

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaveProvider>().loadLeaveRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Requests'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Apply Leave',
            onPressed: () {
               Navigator.pushNamed(context, '/apply-leave');
            },
          )
        ],
      ),
      body: Consumer<LeaveProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(provider.leaveRequests, 'Pending'),
              _buildList(provider.leaveRequests, 'Approved'),
              _buildList(provider.leaveRequests, 'Rejected'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<LeaveModel> allLeaves, String status) {
    // Filter matching status (case insensitive logic needed)
    final leaves = allLeaves.where((l) => l.status.toLowerCase() == status.toLowerCase()).toList();

    if (leaves.isEmpty) {
      return Center(child: Text('No $status requests'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leaves.length,
      itemBuilder: (context, index) {
        return _LeaveCard(
          leave: leaves[index], 
          isManager: _isManager,
          onAction: (id, newStatus) {
            context.read<LeaveProvider>().updateStatus(id, newStatus);
          }
        );
      },
    );
  }
}

class _LeaveCard extends StatelessWidget {
  final LeaveModel leave;
  final bool isManager;
  final Function(int, String) onAction;

  const _LeaveCard({required this.leave, required this.isManager, required this.onAction});

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.orange;
    if (leave.status == 'Approved') statusColor = Colors.green;
    if (leave.status == 'Rejected') statusColor = Colors.red;

    final days = leave.endDate.difference(leave.startDate).inDays + 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(leave.employeeName.isNotEmpty ? leave.employeeName : 'Me', // Fallback
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(leave.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('MMM dd').format(leave.startDate)} - ${DateFormat('MMM dd').format(leave.endDate)}  ($days days)',
                   style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
             const SizedBox(height: 4),
            Text('Type: ${leave.leaveType} ${leave.isHalfDay ? '(Half Day)' : ''}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
             Text('Reason: ${leave.reason}', style: const TextStyle(fontStyle: FontStyle.italic)),
             
            if (isManager && leave.status == 'Pending') ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _confirmAction(context, 'Rejected'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Reject'),
                  ),
                   const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _confirmAction(context, 'Approved'),
                     style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text('Approve'),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
  
  void _confirmAction(BuildContext context, String newStatus) {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text('Confirm $newStatus'),
      content: Text('Are you sure you want to mark this request as $newStatus?'),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(c), child: const Text('Cancel')),
        ElevatedButton(onPressed: (){
          Navigator.pop(c);
          onAction(leave.id!, newStatus);
        }, child: const Text('Confirm')),
      ],
    ));
  }
}
