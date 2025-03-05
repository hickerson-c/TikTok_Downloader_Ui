import 'package:flutter/material.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

class DownloadsScreen extends StatefulWidget {
  final String saveDirectory; // ✅ Accepts user-selected folder

  const DownloadsScreen({super.key, required this.saveDirectory});

  @override
  DownloadsScreenState createState() => DownloadsScreenState();
}

class DownloadsScreenState extends State<DownloadsScreen> {
  List<File> downloadedVideos = [];

  @override
  void initState() {
    super.initState();
    loadDownloads();
  }

  /// ✅ Loads all downloaded videos from the user-selected folder
  Future<void> loadDownloads() async {
    Directory saveDirectory = Directory(widget.saveDirectory); // ✅ Use correct folder

    if (!await saveDirectory.exists()) {
      debugPrint("⚠️ Folder does not exist: ${widget.saveDirectory}");
      return;
    }

    List<File> files = saveDirectory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith(".mp4"))
        .toList();

    if (mounted) {
      setState(() {
        downloadedVideos = files;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Downloaded Videos")),
      body: downloadedVideos.isEmpty
          ? const Center(child: Text("No downloads found"))
          : ListView.builder(
              itemCount: downloadedVideos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(downloadedVideos[index].path.split('/').last),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(file: downloadedVideos[index]),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// ✅ Video Player for Downloaded Videos
class VideoPlayerScreen extends StatefulWidget {
  final File file;
  const VideoPlayerScreen({super.key, required this.file});

  @override
  VideoPlayerScreenState createState() => VideoPlayerScreenState();
}

class VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool isPlaying = false; // ✅ Track play state

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Playing Video")),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isPlaying = !isPlaying;
            isPlaying ? _controller.play() : _controller.pause();
          });
        },
        child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}