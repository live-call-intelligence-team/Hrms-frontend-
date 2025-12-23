import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/recruitment_provider.dart';

class JobDescriptionsScreen extends StatefulWidget {
  const JobDescriptionsScreen({super.key});

  @override
  State<JobDescriptionsScreen> createState() => _JobDescriptionsScreenState();
}

class _JobDescriptionsScreenState extends State<JobDescriptionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecruitmentProvider>().fetchJobDescriptions();
    });
  }

  // Placeholder for Create/Edit Job Description Dialog
  // In a real app, this would be a full form. 
  // For now, assume we just view them since we didn't plan a form screen for this explicitly 
  // but we can add a basic dialog if needed.
  // The service has `getJobDescriptions`. 
  // Let's implement lists first.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Descriptions / Roles')),
      body: Consumer<RecruitmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          if (provider.jobDescriptions.isEmpty) return const Center(child: Text("No standardized job roles found."));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.jobDescriptions.length,
            separatorBuilder: (ctx, i) => const Divider(),
            itemBuilder: (context, index) {
              final item = provider.jobDescriptions[index];
              return ListTile(
                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(item.description ?? 'No details provided'),
                trailing: const Icon(Icons.info_outline),
                onTap: () {
                   // Show details dialog
                   showDialog(context: context, builder: (_) => AlertDialog(
                     title: Text(item.title),
                     content: Column(
                       mainAxisSize: MainAxisSize.min,
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(item.description ?? ''),
                         const SizedBox(height: 8),
                         if (item.requiredSkills != null)
                            Text("Skills: ${item.requiredSkills}", style: const TextStyle(fontWeight: FontWeight.bold)),
                       ],
                     ),
                     actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("Close"))],
                   ));
                },
              );
            },
          );
        },
      ),
    );
  }
}
