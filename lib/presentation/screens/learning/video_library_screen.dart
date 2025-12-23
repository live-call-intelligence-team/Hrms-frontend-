import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../state/providers/video_provider.dart';

class VideoLibraryScreen extends StatefulWidget {
  const VideoLibraryScreen({super.key});

  @override
  State<VideoLibraryScreen> createState() => _VideoLibraryScreenState();
}

class _VideoLibraryScreenState extends State<VideoLibraryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch videos on init
    Future.microtask(() =>
        Provider.of<VideoProvider>(context, listen: false).fetchVideos());
  }

  Future<void> _launchVideo(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No video URL available')),
      );
      return;
    }
    
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch video')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Library'),
      ),
      body: Consumer<VideoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
                  const SizedBox(height: 16),
                  Text('Error: ${provider.error}'),
                  TextButton(
                    onPressed: () => provider.fetchVideos(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.videos.isEmpty) {
            return const Center(child: Text('No videos available'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.videos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final video = provider.videos[index];
              return Card(
                elevation: 2,
                child: ListTile(
                  leading: Container(
                    width: 80,
                    height: 60,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.play_circle_outline, size: 32),
                  ),
                  title: Text(
                    video.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Duration: ${video.duration} mins'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _launchVideo(video.youtubeUrl),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
