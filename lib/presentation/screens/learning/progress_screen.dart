import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../state/providers/auth_provider.dart';
import '../../../state/providers/learning_provider.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<LearningProvider>().fetchProgress(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Learning Progress'),
      ),
      body: Consumer<LearningProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.error != null) {
             return Center(child: Text('Error: ${provider.error}', style: const TextStyle(color: AppTheme.errorColor)));
          }

          if (provider.progressList.isEmpty) {
            return const Center(child: Text('No progress data available.'));
          }

          // Calculate overall stats (naive approach)
          double totalPercent = 0;
          for (var p in provider.progressList) {
            totalPercent += p.progressPercentage;
          }
          double avgPercent = totalPercent / provider.progressList.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildSummaryCard(context, avgPercent / 100),
                const SizedBox(height: 24),
                _buildDetailedProgress(provider.progressList),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, double value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Overall Completion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 150,
              width: 150,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 12,
                backgroundColor: Colors.grey.shade100,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedProgress(List<dynamic> items) {
    return Column(
      children: items.map((m) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Course #${m.courseId}', style: const TextStyle(fontWeight: FontWeight.w600)),
                   Text('${(m.progressPercentage as double).toInt()}%'),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: m.progressPercentage / 100,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(5),
                color: m.progressPercentage >= 100 ? AppTheme.successColor : AppTheme.primaryColor,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
