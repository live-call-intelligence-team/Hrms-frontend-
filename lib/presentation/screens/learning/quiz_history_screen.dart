import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../state/providers/auth_provider.dart';
import '../../../state/providers/learning_provider.dart';
import 'package:intl/intl.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<LearningProvider>().fetchQuizHistory(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz History'),
      ),
      body: Consumer<LearningProvider>(
        builder: (context, provider, child) {
           if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}', style: const TextStyle(color: AppTheme.errorColor)));
          }

          if (provider.quizHistory.isEmpty) {
            return const Center(child: Text('No quiz history found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.quizHistory.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final item = provider.quizHistory[index];
              final isPassed = item.result;
              final dateStr = item.completedAt != null 
                  ? DateFormat('yyyy-MM-dd HH:mm').format(item.completedAt!) 
                  : 'N/A';
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isPassed ? AppTheme.successColor.withOpacity(0.1) : AppTheme.errorColor.withOpacity(0.1),
                  child: Icon(
                    isPassed ? Icons.check : Icons.close,
                    color: isPassed ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                ),
                title: Text('Question: ${item.question}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Answer: ${item.answer}'),
                    Text('Attempted on: $dateStr', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPassed ? AppTheme.successColor : AppTheme.errorColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPassed ? 'Correct' : 'Incorrect',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
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
