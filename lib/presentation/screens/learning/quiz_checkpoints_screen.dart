import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../state/providers/learning_provider.dart';

class QuizCheckpointsScreen extends StatefulWidget {
  const QuizCheckpointsScreen({super.key});

  @override
  State<QuizCheckpointsScreen> createState() => _QuizCheckpointsScreenState();
}

class _QuizCheckpointsScreenState extends State<QuizCheckpointsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningProvider>().fetchCheckpoints();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Checkpoints'),
      ),
      body: Consumer<LearningProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
             return Center(child: Text('Error: ${provider.error}', style: const TextStyle(color: AppTheme.errorColor)));
          }

          if (provider.checkpoints.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flag_outlined, size: 80, color: AppTheme.primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    'No Active Checkpoints',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No checkpoints configured in the system.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.checkpoints.length,
            itemBuilder: (context, index) {
              final cp = provider.checkpoints[index];
              return Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.quiz, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              cp.question,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (cp.required)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Required', style: TextStyle(color: Colors.orange, fontSize: 10)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Video Timestamp: ${cp.timestamp}s'),
                      const SizedBox(height: 8),
                      Text('Correct Answer: ${cp.correctAnswer}', style: const TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
