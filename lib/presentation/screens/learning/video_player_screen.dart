import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../data/models/video_model.dart';
import '../../../data/services/progress_service.dart';
import 'quiz_screen.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoModel video;
  final VoidCallback? onComplete;

  const VideoPlayerScreen({super.key, required this.video, this.onComplete});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  final ProgressService _progressService = ProgressService();
  bool _isPlayerReady = false;
  
  // Progress tracking
  int _lastReportedPercentage = 0;
  
  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.video.youtubeUrl) ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    )..addListener(_listener);
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      // Calculate progress
      final duration = _controller.metadata.duration.inSeconds;
      final position = _controller.value.position.inSeconds;

      if (duration > 0) {
        final percentage = (position / duration * 100).toInt();
        
        // Report every 5% progress or if completed
        if (percentage > _lastReportedPercentage + 5 || percentage >= 90) {
           _lastReportedPercentage = percentage;
           _progressService.updateProgress(widget.video.id, percentage, position);
        }

        // Check for checkpoints (simplified: just log or show toast for now, can be expanded to overlay)
        // In a real app, we would pause and show a dialog here.
      }
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.deepPurple,
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (metaData) {
           _progressService.updateProgress(widget.video.id, 100, _controller.metadata.duration.inSeconds);
           if (widget.onComplete != null) widget.onComplete!();
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video Completed!')));
        },
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.video.title),
          ),
          body: Column(
            children: [
              player,
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.video.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    // If checkpoints exist, show them as a list below
                    if (widget.video.checkpoints.isNotEmpty) ...[
                      const Divider(),
                      const Text("Quizzes", style: TextStyle(fontWeight: FontWeight.bold)),
                      ...widget.video.checkpoints.map((cp) => ListTile(
                        leading: const Icon(Icons.quiz, color: Colors.deepPurple),
                        title: Text(cp.question),
                        subtitle: Text("At ${cp.timestamp} seconds"),
                        trailing: OutlinedButton(
                          child: const Text("Take Quiz"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuizScreen(checkpoint: cp),
                              ),
                            );
                          },
                        ),
                      )),
                    ]
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
