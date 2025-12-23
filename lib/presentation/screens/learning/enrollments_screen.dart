import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../state/providers/course_provider.dart';
import '../../../state/providers/auth_provider.dart';
import '../../../data/models/course_model.dart';

class EnrollmentsScreen extends StatefulWidget {
  const EnrollmentsScreen({super.key});

  @override
  State<EnrollmentsScreen> createState() => _EnrollmentsScreenState();
}

class _EnrollmentsScreenState extends State<EnrollmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<CourseProvider>(context, listen: false)
            .fetchEnrolledCourses(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Enrollments'),
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Text(
                'Error: ${provider.error}',
                style: const TextStyle(color: AppTheme.errorColor),
              ),
            );
          }

          if (provider.enrolledCourses.isEmpty) {
            return const Center(child: Text('No enrollments found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.enrolledCourses.length,
            itemBuilder: (context, index) {
              final course = provider.enrolledCourses[index];
              return EnrollmentCard(course: course);
            },
          );
        },
      ),
    );
  }
}

class EnrollmentCard extends StatelessWidget {
  final CourseModel course;

  const EnrollmentCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    // Determine progress color
    final double progress = course.progress ?? 0.0;
    final bool isCompleted = progress >= 100.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    course.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.successColor.withOpacity(0.1)
                        : AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCompleted ? 'Completed' : 'In Progress',
                    style: TextStyle(
                      color: isCompleted
                          ? AppTheme.successColor
                          : AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress / 100, // Normalize to 0-1
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Progress: ${(progress).toInt()}%',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            if (course.duration != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Duration: ${course.duration}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
