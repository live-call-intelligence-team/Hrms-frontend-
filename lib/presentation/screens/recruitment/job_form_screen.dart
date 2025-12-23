import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/recruitment_provider.dart';
import '../../../data/models/job_description_model.dart';
import 'package:intl/intl.dart';

class JobFormScreen extends StatefulWidget {
  const JobFormScreen({super.key});

  @override
  State<JobFormScreen> createState() => _JobFormScreenState();
}

class _JobFormScreenState extends State<JobFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  int? _selectedJobDescId;
  final TextEditingController _positionsController = TextEditingController();
  String _selectedEmploymentType = 'Full-time';
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  DateTime _postingDate = DateTime.now();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Ensure descriptions are loaded
    if (context.read<RecruitmentProvider>().jobDescriptions.isEmpty) {
        context.read<RecruitmentProvider>().fetchJobDescriptions();
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _selectedJobDescId != null) {
      setState(() => _isLoading = true);
      
      final Map<String, dynamic> data = {
        'job_description_id': _selectedJobDescId,
        'number_of_positions': int.parse(_positionsController.text),
        'employment_type': _selectedEmploymentType,
        'location': _locationController.text,
        'salary': int.tryParse(_salaryController.text),
        'posting_date': DateFormat('yyyy-MM-dd').format(_postingDate),
        'approval_status': 'pending', // Default
      };

      final success = await context.read<RecruitmentProvider>().createJobPosting(data);
      
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job Created')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create job')));
        }
      }
    } else if (_selectedJobDescId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Job Role')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Job Posting')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<RecruitmentProvider>(
                builder: (context, provider, child) {
                  return DropdownButtonFormField<int>(
                    value: _selectedJobDescId,
                    decoration: const InputDecoration(labelText: 'Job Role (Description)', border: OutlineInputBorder()),
                    items: provider.jobDescriptions.map((desc) {
                      return DropdownMenuItem<int>(
                        value: desc.id,
                        child: Text(desc.title),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedJobDescId = val),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _positionsController,
                keyboardType: TextInputType.number,
                 decoration: const InputDecoration(labelText: 'Number of Positions', border: OutlineInputBorder()),
                 validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedEmploymentType,
                decoration: const InputDecoration(labelText: 'Employment Type', border: OutlineInputBorder()),
                items: ['Full-time', 'Part-time', 'Contract', 'Internship']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _selectedEmploymentType = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                 decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                 validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _salaryController,
                keyboardType: TextInputType.number,
                 decoration: const InputDecoration(labelText: 'Salary (Optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Post Job'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
