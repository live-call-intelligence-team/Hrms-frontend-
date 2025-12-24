import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../state/providers/attendance_provider.dart';
import 'package:intl/intl.dart';

class AttendanceDashboardScreen extends StatefulWidget {
  const AttendanceDashboardScreen({super.key});

  @override
  State<AttendanceDashboardScreen> createState() => _AttendanceDashboardScreenState();
}

class _AttendanceDashboardScreenState extends State<AttendanceDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load attendance data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().loadTodayAttendance();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        elevation: 0,
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.todayAttendance == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final attendance = provider.todayAttendance;
          final isPunchedIn = attendance?.status == 'Present' && attendance?.punchOut == null && attendance?.punchIn != null;
          // Simple logic: If punched in but no punch out, user is "In".
          // Adjust logic based on exact backend status strings if needed.

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadTodayAttendance();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Card
                  _buildStatusCard(context, attendance),
                  const SizedBox(height: 24),

                  // Punch Actions
                  _buildPunchControls(context, provider),

                  const SizedBox(height: 24),

                  // Today's Summary
                  _buildTodaySummary(attendance),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActions(),
                  
                   const SizedBox(height: 24),
                  
                  // Month Stats (Placeholder for now)
                   const Text(
                    'This Month',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildMonthStatsPlaceholder(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, dynamic attendance) {
    bool isPresent = attendance?.punchIn != null && attendance?.punchOut == null;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Text(
            DateTime.now().toString().substring(11, 16), // Simple digital clock
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
           const SizedBox(height: 20),
           Container(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             decoration: BoxDecoration(
               color: Colors.white.withOpacity(0.2),
               borderRadius: BorderRadius.circular(20),
             ),
             child: Text(
               isPresent ? 'PUNCHED IN' : 'NOT PUNCHED IN',
               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
             ),
           )
        ],
      ),
    );
  }

  Widget _buildPunchControls(BuildContext context, AttendanceProvider provider) {
    final attendance = provider.todayAttendance;
    final bool canPunchIn = attendance?.punchIn == null;
    final bool canPunchOut = attendance?.punchIn != null && attendance?.punchOut == null;

    if (attendance?.punchIn != null && attendance?.punchOut != null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text("Attendance completed for today"),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: canPunchIn
                ? () => _confirmPunch(context, provider, 'in')
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Column(
              children: [
                Icon(Icons.login),
                SizedBox(height: 4),
                Text('PUNCH IN'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: canPunchOut
                ? () => _confirmPunch(context, provider, 'out')
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Column(
              children: [
                Icon(Icons.logout),
                SizedBox(height: 4),
                Text('PUNCH OUT'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmPunch(BuildContext context, AttendanceProvider provider, String type) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Punch ${type == 'in' ? 'In' : 'Out'}'),
        content: Text('Are you sure you want to punch ${type == 'in' ? 'in' : 'out'} now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await provider.punch(type);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Succesfully punched $type')),
          );
        }
      } else {
        if (mounted && provider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.errorMessage!)),
          );
        }
      }
    }
  }

  Widget _buildTodaySummary(dynamic attendance) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Arrival', attendance?.punchIn?.substring(11, 16) ?? '--:--'),
                _buildSummaryItem('Departure', attendance?.punchOut?.substring(11, 16) ?? '--:--'),
                _buildSummaryItem('Hours', attendance?.totalHours ?? '--:--'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(child: _QuickActionCard(
          icon: Icons.calendar_today, 
          label: 'Leave', 
          onTap: () => Navigator.pushNamed(context, '/leave-requests'),
        )),
        const SizedBox(width: 12),
        Expanded(child: _QuickActionCard(
          icon: Icons.timer, 
          label: 'Permission',
           onTap: () => Navigator.pushNamed(context, '/permission-requests'),
        )),
         const SizedBox(width: 12),
        Expanded(child: _QuickActionCard(
          icon: Icons.history, 
          label: 'History',
           onTap: () => Navigator.pushNamed(context, '/my-attendance'),
        )),
      ],
    );
  }
  
  Widget _buildMonthStatsPlaceholder() {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!)
      ),
      child: const Center(child: Text('Month Stats & Chart')),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
         padding: const EdgeInsets.symmetric(vertical: 16),
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(12),
           border: Border.all(color: Colors.grey[200]!),
         ),
         child: Column(
           children: [
             Icon(icon, color: Theme.of(context).primaryColor),
             const SizedBox(height: 8),
             Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
           ],
         ),
      ),
    );
  }
}
    