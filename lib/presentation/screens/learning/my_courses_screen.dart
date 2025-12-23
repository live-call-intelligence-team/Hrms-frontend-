import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/course_provider.dart';
import 'course_detail_screen.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().fetchEnrolledCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Courses')),
      body: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.enrolledCourses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                   const SizedBox(height: 16),
                   const Text('No courses enrolled yet.'),
                   const SizedBox(height: 16),
                   ElevatedButton(
                     onPressed: () {
                       // Navigate back or to catalog
                       Navigator.pop(context); 
                     },
                     child: const Text('Browse Courses'),
                   )
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: provider.enrolledCourses.length,
            itemBuilder: (context, index) {
              final course = provider.enrolledCourses[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseDetailScreen(
                          courseId: course.id!,
                          courseTitle: course.title,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          image: course.thumbnailUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(course.thumbnailUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                        child: course.thumbnailUrl == null
                            ? const Center(child: Icon(Icons.book, size: 40, color: Colors.grey))
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            // Progress Bar
                            if (course.progress != null) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${course.progress!.toInt()}% Complete', style: Theme.of(context).textTheme.bodySmall),
                                  if (course.progress! >= 100)
                                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: course.progress! / 100,
                                backgroundColor: Colors.grey[200],
                                color: Colors.deepPurple,
                              ),
                            ] else
                              const Text('Start Learning', style: TextStyle(color: Colors.deepPurple)),
                              
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                   Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CourseDetailScreen(
                                          courseId: course.id!,
                                          courseTitle: course.title,
                                        ),
                                      ),
                                    );
                                },
                                child: Text(course.progress == null ? 'Start' : 'Continue'),
                              ),
                            )
                          ],
                        ),
                      ),
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
