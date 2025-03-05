import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

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

  /// ✅ Loads all downloaded videos
  Future<void> loadDownloads() async {
    final directory = await getApplicationDocumentsDirectory();
    Directory saveDirectory = Directory("${directory.path}/TiktokDownloaderContent");

    if (!await saveDirectory.exists()) {
      await saveDirectory.create(recursive: true);
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
      appBar: AppBar(title: Text("Downloaded Videos")),
      body: downloadedVideos.isEmpty
          ? Center(child: Text("No downloads found"))
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

class VideoPlayerScreen extends StatefulWidget {
  final File file;
  const VideoPlayerScreen({super.key, required this.file});

  @override
  VideoPlayerScreenState createState() => VideoPlayerScreenState();
}

class VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
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
      appBar: AppBar(title: Text("Playing Video")),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying ? _controller.pause() : _controller.play();
          });
        },
        child: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}