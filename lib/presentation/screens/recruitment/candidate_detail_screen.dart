import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../data/models/candidate_model.dart';
import '../../../state/providers/recruitment_provider.dart';

class CandidateDetailScreen extends StatefulWidget {
  final CandidateModel candidate;

  const CandidateDetailScreen({super.key, required this.candidate});

  @override
  State<CandidateDetailScreen> createState() => _CandidateDetailScreenState();
}

class _CandidateDetailScreenState extends State<CandidateDetailScreen> {
  bool _isUpdating = false;

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    final success = await context.read<RecruitmentProvider>().updateCandidateStatus(widget.candidate.id, newStatus);
    setState(() => _isUpdating = false);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to $newStatus')));
      Navigator.pop(context); // Go back to refresh list
    }
  }

  @override
  Widget build(BuildContext context) {
    // Current status
    String status = widget.candidate.status ?? 'Pending';

    return Scaffold(
      appBar: AppBar(title: Text(widget.candidate.fullName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(radius: 40, child: Text(widget.candidate.firstName[0], style: const TextStyle(fontSize: 32))),
                    const SizedBox(height: 16),
                    Text(widget.candidate.fullName, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(widget.candidate.email),
                    Text(widget.candidate.phoneNumber),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _getStatusColor(status)),
                      ),
                      child: Text(status, style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Actions
            const Text("Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (widget.candidate.resumeUrl != null && widget.candidate.resumeUrl!.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('View Resume'),
              onTap: () async {
                 if (await canLaunchUrlString(widget.candidate.resumeUrl!)) {
                   await launchUrlString(widget.candidate.resumeUrl!);
                 } else {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch resume URL')));
                 }
              },
              tileColor: Colors.white,
            ),
            
            const SizedBox(height: 24),
            const Text("Update Hiring Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    onPressed: _isUpdating ? null : () => _updateStatus('Accepted'),
                    child: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    onPressed: _isUpdating ? null : () => _updateStatus('Rejected'),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.orange;
    }
  }
}
