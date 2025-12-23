import 'package:flutter/material.dart';
import '../../../data/models/quiz_checkpoint_model.dart';
import '../../../data/services/quiz_service.dart';

class QuizScreen extends StatefulWidget {
  final QuizCheckpointModel checkpoint;

  const QuizScreen({super.key, required this.checkpoint});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService();
  String? _selectedAnswer;
  bool _isSubmitting = false;
  bool? _isCorrect;

  void _submit() async {
    if (_selectedAnswer == null) return;

    setState(() => _isSubmitting = true);

    try {
      // Logic handled by service calling backend
      final correct = await _quizService.submitQuiz(widget.checkpoint.id, _selectedAnswer!);
      
      if (mounted) {
        setState(() {
          _isCorrect = correct;
          _isSubmitting = false;
        });
        
        _showResultDialog(correct);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showResultDialog(bool correct) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(correct ? 'Correct!' : 'Incorrect'),
        content: Text(correct 
            ? 'Great job! You answered correctly.' 
            : 'Sorry, that was likely incorrect. The correct answer was: ${widget.checkpoint.correctAnswer}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close quiz screen
            },
            child: const Text('Continue Learning'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Assuming choices are comma-separated for simplicity if raw string, 
    // or we might need to parse JSON. Let's assume CSV for this simple implement.
    // If it's JSON, we should parse it in the model. 
    // For now, let's split by comma.
    final List<String> options = widget.checkpoint.choices.split(',').map((e) => e.trim()).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              widget.checkpoint.question,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            ...options.map((option) => RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _selectedAnswer,
              onChanged: _isSubmitting || _isCorrect != null 
                  ? null 
                  : (val) => setState(() => _selectedAnswer = val),
            )),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedAnswer != null && !_isSubmitting ? _submit : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Submit Answer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
