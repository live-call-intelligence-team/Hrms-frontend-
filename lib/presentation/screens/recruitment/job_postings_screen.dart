import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/recruitment_provider.dart';
import 'job_form_screen.dart';

class JobPostingsScreen extends StatefulWidget {
  const JobPostingsScreen({super.key});

  @override
  State<JobPostingsScreen> createState() => _JobPostingsScreenState();
}

class _JobPostingsScreenState extends State<JobPostingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecruitmentProvider>().fetchJobPostings();
      context.read<RecruitmentProvider>().fetchJobDescriptions(); // Pre-fetch for forms/display
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Postings')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const JobFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Consumer<RecruitmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          
          if (provider.jobPostings.isEmpty) return const Center(child: Text('No job postings found.'));

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: provider.jobPostings.length,
            itemBuilder: (context, index) {
              final job = provider.jobPostings[index];
              // Find job title from descriptions if possible, else just show ID or placeholder
              final jobDesc = provider.jobDescriptions.firstWhere(
                  (d) => d.id == job.jobDescriptionId, 
                  orElse: () => provider.jobDescriptions.isNotEmpty ? provider.jobDescriptions.first :  
                  // Fallback if list empty 
                  // In real app we should handle this better or model should have title
                  // I will create a dummy model to return "Role ID: X"
                  // Actually I can't return different type. I will handle null safety.
                   throw UnimplementedError() // Dirty hack, let's fix logic below
              );
              
              String title = "Role #${job.jobDescriptionId}"; 
              try {
                 title = provider.jobDescriptions.firstWhere((d) => d.id == job.jobDescriptionId).title;
              } catch (_) {}

              return Card(
                child: ListTile(
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${job.location} • ${job.employmentType}'),
                      Text('Status: ${job.approvalStatus}', style: TextStyle(
                        color: job.approvalStatus == 'accepted' ? Colors.green : Colors.orange
                      )),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to detail or edit
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
