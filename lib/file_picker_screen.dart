import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'video_list_screen.dart'; // ✅ Import VideoListScreen

class FilePickerScreen extends StatefulWidget {
  const FilePickerScreen({super.key});

  @override
  FilePickerScreenState createState() => FilePickerScreenState();
}

class FilePickerScreenState extends State<FilePickerScreen> {
  String? filePath;

  /// Handles file selection and navigation
Future<void> pickTextFile() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null && result.files.single.path != null) {
      String originalPath = result.files.single.path!;
      final appDir = await getApplicationDocumentsDirectory();
      String newPath = '${appDir.path}/${originalPath.split('/').last}';
      File copiedFile = await File(originalPath).copy(newPath);

      if (!mounted) return; // ✅ Ensures the widget is still in the tree

      setState(() {
        filePath = copiedFile.path;
      });

      debugPrint("✅ Copied file to: $filePath");

      // ✅ Only navigate if widget is still mounted
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoListScreen(filePath: filePath!),
          ),
        );
      }
    }
  } catch (e) {
    debugPrint("❌ Error picking file: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select posts.txt")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Please extract your TikTok data first, then select the 'posts.txt' file from the extracted folder.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickTextFile,
              child: Text("Browse for posts.txt"),
            ),
            if (filePath != null) ...[
              SizedBox(height: 20),
              Text("Selected file: $filePath"),
            ],
          ],
        ),
      ),
    );
  }
}