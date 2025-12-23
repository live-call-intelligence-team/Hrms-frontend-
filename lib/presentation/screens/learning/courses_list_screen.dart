import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/course_provider.dart';
import '../../../state/providers/auth_provider.dart';
import '../../../data/models/course_model.dart';
import 'course_detail_screen.dart';

class CoursesListScreen extends StatefulWidget {
  const CoursesListScreen({super.key});

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Fetch courses on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().fetchCourses();
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<CourseProvider>().fetchEnrolledCourses(authProvider.user!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Courses'),
            Tab(text: 'My Courses'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllCoursesTab(),
          _buildMyCoursesTab(),
        ],
      ),
    );
  }

  Widget _buildAllCoursesTab() {
    return Consumer<CourseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (provider.error != null) {
          return Center(child: Text('Error: ${provider.error}'));
        }

        if (provider.courses.isEmpty) {
          return const Center(child: Text('No courses available.'));
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchCourses(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search courses...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Adjust based on screen width if needed
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: provider.courses.length,
                  itemBuilder: (context, index) {
                    final course = provider.courses[index];
                    return CourseCard(course: course);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyCoursesTab() {
    return Consumer<CourseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text('Error: ${provider.error}'));
        }

        if (provider.enrolledCourses.isEmpty) {
          return const Center(child: Text('You are not enrolled in any courses.'));
        }

        return RefreshIndicator(
          onRefresh: () {
             final authProvider = Provider.of<AuthProvider>(context, listen: false);
             if (authProvider.user != null) {
               return provider.fetchEnrolledCourses(authProvider.user!.id);
             }
             return Future.value();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: provider.enrolledCourses.length,
            itemBuilder: (context, index) {
              final course = provider.enrolledCourses[index];
              return Card(
                child: ListTile(
                  leading: course.thumbnailUrl != null 
                      ? Image.network(course.thumbnailUrl!, width: 50, height: 50, fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image))
                      : const Icon(Icons.book, size: 50),
                  title: Text(course.title),
                  subtitle: course.progress != null 
                    ? LinearProgressIndicator(value: course.progress! / 100)
                    : const Text('Start learning'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class CourseCard extends StatelessWidget {
  final CourseModel course;
  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
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
            Expanded(
              child: course.thumbnailUrl != null && course.thumbnailUrl!.isNotEmpty
                  ? Image.network(
                      course.thumbnailUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.image_not_supported))),
                    )
                  : Container(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      child: const Center(child: Icon(Icons.book, size: 50, color: Colors.deepPurple)),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    course.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (course.duration != null)
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(course.duration!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
