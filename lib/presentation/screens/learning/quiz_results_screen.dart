import 'package:flutter/material.dart';

class QuizResultsScreen extends StatelessWidget {
  final bool isCorrect;
  final String correctAnswer;
  final String question;
  final VoidCallback onRetry;
  final VoidCallback onContinue;

  const QuizResultsScreen({
    super.key,
    required this.isCorrect,
    required this.correctAnswer,
    required this.question,
    required this.onRetry,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Result')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              size: 100,
              color: isCorrect ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              isCorrect ? 'Correct!' : 'Incorrect',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: isCorrect ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (!isCorrect) ...[
              const Text(
                'The correct answer was:',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                correctAnswer,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Continue Learning'),
              ),
            ),
            if (!isCorrect) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onRetry,
                child: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
