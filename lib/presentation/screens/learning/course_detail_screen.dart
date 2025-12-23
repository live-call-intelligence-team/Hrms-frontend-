import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/course_provider.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/video_model.dart';
import 'video_player_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final int courseId;
  final String courseTitle;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Fetch course details on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().fetchCourseDetail(widget.courseId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    context.read<CourseProvider>().clearSelectedCourse(); // Cleanup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
             // Show a scaffold with loader properly
             return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (provider.error != null) {
            return Scaffold(
              appBar: AppBar(title: Text(widget.courseTitle)),
              body: Center(child: Text('Error: ${provider.error}')),
            );
          }

          final course = provider.selectedCourse;
          if (course == null) {
             return const Scaffold(body: Center(child: Text('Course not found')));
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(course.title, textScaleFactor: 1.0),
                    background: course.thumbnailUrl != null
                        ? Image.network(
                            course.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(color: Colors.grey),
                          )
                        : Container(color: Colors.deepPurple[100]),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (course.duration != null)
                            Chip(
                              avatar: const Icon(Icons.access_time, size: 16),
                              label: Text(course.duration!),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            course.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Enroll logic if needed, or Continue
                              },
                              child: const Text('Enroll / Continue Learning'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.deepPurple,
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(text: "Content"),
                        Tab(text: "Quizzes"),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildContentTab(course),
                // Placeholder for Quizzes Tab
                const Center(child: Text("Quizzes will appear here based on checkpoints")),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentTab(CourseModel course) {
    if (course.videos.isEmpty) {
      return const Center(child: Text("No content available yet."));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(8.0),
      itemCount: course.videos.length,
      separatorBuilder: (ctx, index) => const Divider(),
      itemBuilder: (context, index) {
        final video = course.videos[index];
        return ListTile(
          leading: const Icon(Icons.play_circle_fill, color: Colors.deepPurple),
          title: Text(video.title),
          subtitle: Text(video.duration > 0 ? '${video.duration} min' : 'Video'),
          trailing: const Icon(Icons.lock_open, size: 20, color: Colors.green), // Logic for lock/unlock
          onTap: () {
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (_) => VideoPlayerScreen(
                    video: video,
                    onComplete: () {
                      // Optionally refresh course details or mark item as done in UI
                    },
                 ),
               ),
             );
          },
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
