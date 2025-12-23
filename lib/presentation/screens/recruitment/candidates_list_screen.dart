import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/recruitment_provider.dart';
import 'candidate_detail_screen.dart';
import 'candidate_form_screen.dart';

class CandidatesListScreen extends StatefulWidget {
  const CandidatesListScreen({super.key});

  @override
  State<CandidatesListScreen> createState() => _CandidatesListScreenState();
}

class _CandidatesListScreenState extends State<CandidatesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecruitmentProvider>().fetchCandidates();
      context.read<RecruitmentProvider>().fetchJobPostings(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Candidates')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const CandidateFormScreen()));
        },
        child: const Icon(Icons.person_add),
      ),
      body: Consumer<RecruitmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          
          if (provider.candidates.isEmpty) return const Center(child: Text('No candidates found.'));

          // Filter logic could go here based on _searchController

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: provider.candidates.length,
            itemBuilder: (context, index) {
              final candidate = provider.candidates[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(candidate.firstName[0])),
                  title: Text(candidate.fullName),
                  subtitle: Text('${candidate.email}\nStatus: ${candidate.status ?? "Pending"}'),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CandidateDetailScreen(candidate: candidate),
                      ),
                    );
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
