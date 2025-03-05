import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'downloads_screen.dart';

// Function to generate a UTC-based filename
String getUtcFilename() {
  DateTime now = DateTime.now().toUtc();
  return "${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}_"
         "${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}.mp4";
}

String _twoDigits(int n) => n.toString().padLeft(2, '0');

class VideoListScreen extends StatefulWidget {
  final String filePath;
  final String saveDirectory; // ✅ User-selected save folder

  const VideoListScreen({super.key, required this.filePath, required this.saveDirectory});

  @override
  VideoListScreenState createState() => VideoListScreenState();
}

class VideoListScreenState extends State<VideoListScreen> {
  List<Map<String, dynamic>> videoList = [];
  bool selectAll = false;
  bool isDownloading = false;
  double progress = 0.0;
  int skippedCount = 0; // ✅ Store skipped videos count
  int totalVideos = 0; // ✅ Store total valid videos count

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  /// ✅ Extracts video URLs and dates from the Posts.txt file
  Future<List<Map<String, dynamic>>> extractData(String filePath) async {
    List<Map<String, dynamic>> extractedData = [];
    int skipped = 0;

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint("❌ Error: File does not exist at $filePath");
        return [];
      }

      List<String> lines = await file.readAsLines();
      String? currentDate;

      for (String line in lines) {
        if (line.startsWith("Date:")) {
          currentDate = line.split(": ")[1];
        } else if (line.startsWith("Link:") && currentDate != null) {
          String videoUrl = line.replaceFirst("Link: ", "").trim();

          if (Uri.tryParse(videoUrl)?.hasAbsolutePath ?? false) {
            extractedData.add({"date": currentDate, "link": videoUrl});
          } else {
            skipped++; // ✅ Count invalid URLs
          }
        }
      }

      debugPrint("📊 Total Videos Found: ${extractedData.length} | Skipped Invalid: $skipped"); // ✅ Log summary

      if (mounted) {
        setState(() {
          totalVideos = extractedData.length; // ✅ Update total video count
          skippedCount = skipped; // ✅ Update skipped count
        });
      }
    } catch (e) {
      debugPrint("❌ Error extracting data: $e");
    }

    return extractedData;
  }

  /// ✅ Loads videos from extracted data
  Future<void> loadVideos() async {
    List<Map<String, dynamic>> extractedData = await extractData(widget.filePath);
    if (mounted) {
      setState(() {
        videoList = extractedData.map((video) {
          return {"date": video['date'], "link": video['link'], "selected": false};
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

  /// ✅ Downloads selected videos
  Future<void> downloadSelectedVideos() async {
    List<Map<String, dynamic>> selectedVideos = videoList.where((video) => video["selected"]).toList();

    if (selectedVideos.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No videos selected!")),
        );
      }
      return;
    }

    setState(() {
      isDownloading = true;
      progress = 0.0;
    });

    Directory saveDirectory = Directory(widget.saveDirectory);
    if (!await saveDirectory.exists()) {
      await saveDirectory.create(recursive: true);
    }

    for (int i = 0; i < selectedVideos.length; i++) {
      String videoUrl = selectedVideos[i]["link"];
      String fileName = getUtcFilename(); // ✅ Generate UTC-based filename
      String filePath = "${saveDirectory.path}${Platform.pathSeparator}$fileName";

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Download Complete! Files saved to ${widget.saveDirectory}")),
      );

      setState(() {
        isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Videos to Download")),
      body: Column(
        children: [
          // ✅ Show video summary (total found & skipped)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Total Videos: $totalVideos | Skipped: $skippedCount",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // ✅ "Download Selected Videos" button moved to the TOP
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: videoList.any((video) => video["selected"]) ? downloadSelectedVideos : null,
              child: const Text("Download Selected Videos"),
            ),
          ),

          // ✅ "View Downloads" Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DownloadsScreen(saveDirectory: widget.saveDirectory), // ✅ Pass correct folder
                  ),
                );
              },
              child: const Text("View Downloads"),
            ),
          ),

          Expanded(
            child: videoList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: videoList.length,
                    itemBuilder: (context, index) {
                      var video = videoList[index];

                      return CheckboxListTile(
                        title: Text(video['date']), // ✅ Show only date
                        subtitle: const Text("TikTok Video"), // ✅ Hide long URL
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

          // ✅ "Select All / Deselect All" button moved to the BOTTOM
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: toggleSelectAll,
              child: Text(selectAll ? "Deselect All" : "Select All"),
            ),
          ),
        ],
      ),
    );
  }
}