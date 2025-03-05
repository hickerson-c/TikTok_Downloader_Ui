import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'storage_helper.dart';
import 'downloads_screen.dart';

class VideoListScreen extends StatefulWidget {
  final String filePath;
  const VideoListScreen({super.key, required this.filePath});

  @override
  VideoListScreenState createState() => VideoListScreenState();
}

class VideoListScreenState extends State<VideoListScreen> {
  List<Map<String, dynamic>> videoList = [];
  bool selectAll = false;
  bool isDownloading = false;
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  /// ✅ Loads videos and extracts only the date (YYYY-MM-DD)
  Future<void> loadVideos() async {
    List<Map<String, dynamic>> extractedData = await StorageHelper.extractData(widget.filePath);
    if (mounted) {
      setState(() {
        videoList = extractedData.map((video) {
          return {"date": video['date'].split(" ")[0], "link": video['link'], "selected": false};
        }).toList();
      });
    }
  }

  /// ✅ Toggles selection for all videos
  void toggleSelectAll() {
    setState(() {
      selectAll = !selectAll;
      for (var video in videoList) {
        video["selected"] = selectAll;
      }
    });
  }

  /// ✅ Downloads selected videos to the App Folder
  Future<void> downloadSelectedVideos() async {
    List<Map<String, dynamic>> selectedVideos = videoList.where((video) => video["selected"]).toList();

    if (selectedVideos.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No videos selected!")),
        );
      }
      return;
    }

    setState(() {
      isDownloading = true;
      progress = 0.0;
    });

    final directory = await getApplicationDocumentsDirectory();
    Directory saveDirectory = Directory("${directory.path}/TiktokDownloaderContent");

    if (!await saveDirectory.exists()) {
      await saveDirectory.create(recursive: true);
    }

    Map<String, int> dateCount = {};

    for (int i = 0; i < selectedVideos.length; i++) {
      String videoUrl = selectedVideos[i]["link"];
      String baseFileName = selectedVideos[i]["date"];

      if (!dateCount.containsKey(baseFileName)) {
        dateCount[baseFileName] = 1;
      } else {
        dateCount[baseFileName] = dateCount[baseFileName]! + 1;
      }

      String fileName = (dateCount[baseFileName]! > 1)
          ? "${baseFileName}_${dateCount[baseFileName]}.mp4"
          : "$baseFileName.mp4";

      String filePath = "${saveDirectory.path}/$fileName";

      try {
        var response = await http.get(Uri.parse(videoUrl));

        if (response.statusCode == 200) {
          File file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          debugPrint("📁 Saved to: $filePath");
        } else {
          debugPrint("❌ Failed to download: $videoUrl");
        }
      } catch (e) {
        debugPrint("❌ Error downloading $videoUrl: $e");
      }

      if (mounted) {
        setState(() {
          progress = (i + 1) / selectedVideos.length;
        });
      }
    }

    if (mounted) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("✅ Download Complete! Files saved to App Folder.")),
      );

      setState(() {
        isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Videos to Download")),
      body: Column(
        children: [
          // ✅ "View Downloads" Button
          Padding(
            padding: EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DownloadsScreen()));
              },
              child: Text("View Downloads"),
            ),
          ),
          // ✅ Select All / Deselect All Button
          Padding(
            padding: EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: toggleSelectAll,
              child: Text(selectAll ? "Deselect All" : "Select All"),
            ),
          ),
          // ✅ Video List (Now Showing Only Dates)
          Expanded(
            child: videoList.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: videoList.length,
                    itemBuilder: (context, index) {
                      var video = videoList[index];
                      return CheckboxListTile(
                        title: Text(video['date']),
                        value: video["selected"],
                        onChanged: (bool? value) {
                          setState(() {
                            videoList[index]["selected"] = value!;
                          });
                        },
                      );
                    },
                  ),
          ),
          // ✅ Progress Bar (Visible only while downloading)
          if (isDownloading)
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Text("Downloading... ${(progress * 100).toStringAsFixed(0)}%"),
                  SizedBox(height: 10),
                  LinearProgressIndicator(value: progress),
                ],
              ),
            ),
          // ✅ Download Button
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: videoList.any((video) => video["selected"]) ? downloadSelectedVideos : null,
              child: Text("Download Selected Videos"),
            ),
          ),
        ],
      ),
    );
  }
}