import 'dart:io';
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
  String? selectedDirectory;

  /// ✅ Shortens the path to show only the last two folder names
  String getShortenedPath(String fullPath) {
    List<String> parts = fullPath.split(Platform.pathSeparator);
    if (parts.length >= 2) {
      return "${parts[parts.length - 2]}/${parts.last}"; // Show last 2 folders
    }
    return fullPath; // Fallback if path is too short
  }

  /// Allows user to select a directory to save files
  Future<void> pickSaveFolder() async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    if (directoryPath != null) {
      setState(() {
        selectedDirectory = directoryPath;
      });

      debugPrint("✅ Selected save folder: $selectedDirectory");
    }
  }

  /// Handles file selection and navigation
  Future<void> pickTextFile() async {
    try {
      if (selectedDirectory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ Please select a save folder first.")),
        );
        return;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result != null && result.files.single.path != null) {
        String originalPath = result.files.single.path!;
        String newPath = '$selectedDirectory${Platform.pathSeparator}${originalPath.split(Platform.pathSeparator).last}';

        // ✅ Copy file to the user-selected directory
        File copiedFile = await File(originalPath).copy(newPath);

        if (!mounted) return; // ✅ Ensure widget is still active

        setState(() {
          filePath = copiedFile.path;
        });

        debugPrint("✅ Copied file to: $filePath");

        // ✅ Navigate only if the widget is still mounted
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoListScreen(
                filePath: filePath!,
                saveDirectory: selectedDirectory!, // ✅ Pass selected folder path
              ),
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
      appBar: AppBar(title: const Text("Select File & Save Location")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Step 1: Select a folder where the extracted file should be saved.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: pickSaveFolder,
              child: const Text("Choose Save Folder"),
            ),
            if (selectedDirectory != null) ...[
              const SizedBox(height: 10),
              Text("Save Location: ${getShortenedPath(selectedDirectory!)}"), // ✅ Shortened Path
            ],
            const SizedBox(height: 20),
            const Text(
              "Step 2: Select the 'posts.txt' file from the extracted TikTok data.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: pickTextFile,
              child: const Text("Browse for posts.txt"),
            ),
            if (filePath != null) ...[
              const SizedBox(height: 20),
              Text("Selected file: ${getShortenedPath(filePath!)}"), // ✅ Shortened Path
            ],
          ],
        ),
      ),
    );
  }
}