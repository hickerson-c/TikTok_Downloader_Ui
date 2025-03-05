import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class StorageHelper {
  
  /// ✅ Request storage permission based on platform
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.request();
      return status.isGranted;
    } else {
      var status = await Permission.photos.request();
      return status.isGranted;
    }
  }

  /// ✅ Copies file to `TiktokDownloaderContent` inside Documents directory
  static Future<File?> copyFileToAppDir(String filePath) async {
    // ✅ Request permission first
    if (!await requestStoragePermission()) {
      debugPrint("❌ Permission denied");
      return null;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final customDir = Directory('${appDir.path}${Platform.pathSeparator}TiktokDownloaderContent');

    // ✅ Create the directory if it doesn't exist
    if (!await customDir.exists()) {
      await customDir.create(recursive: true);
      debugPrint("📁 Created directory: ${customDir.path}");
    }

    final newFilePath = '${customDir.path}${Platform.pathSeparator}${filePath.split(Platform.pathSeparator).last}';

    // ✅ Check if file already exists
    if (await File(newFilePath).exists()) {
      debugPrint("⚠️ File already exists at: $newFilePath");
      return File(newFilePath);
    }

    // ✅ Copy the file to the new directory with error handling
    try {
      File copiedFile = await File(filePath).copy(newFilePath);
      debugPrint("✅ File successfully copied to: $newFilePath");
      return copiedFile;
    } catch (e) {
      debugPrint("❌ Error copying file: $e");
      return null;
    }
  }

  /// ✅ Reads & extracts "Date" (YYYY-MM-DD only) and "Link" entries from Posts.txt
  static Future<List<Map<String, dynamic>>> extractData(String filePath) async {
    List<Map<String, dynamic>> extractedEntries = [];
    File file = File(filePath);

    try {
      List<String> lines = await file.readAsLines(); // Read lines asynchronously

      RegExp datePattern = RegExp(r"^Date:\s*(\d{4}-\d{2}-\d{2})");
      RegExp linkPattern = RegExp(r"^Link:\s*(https?://\S+)");

      String? currentDate;
      String? currentLink;

      for (String line in lines) {
        line = line.trim();  // Remove extra spaces

        if (datePattern.hasMatch(line)) {
          currentDate = datePattern.firstMatch(line)!.group(1)!; // Extract only YYYY-MM-DD
        }
        if (linkPattern.hasMatch(line)) {
          currentLink = linkPattern.firstMatch(line)!.group(1)!;
        }

        if (currentDate != null && currentLink != null) {
          extractedEntries.add({
            "date": currentDate, // Now only stores YYYY-MM-DD
            "link": currentLink,
            "selected": false // Default: not selected
          });
          currentDate = null;
          currentLink = null;
        }
      }

      debugPrint("✅ Extracted Video List (Dates Only): $extractedEntries");
    } catch (e) {
      debugPrint("❌ Error reading file: $e");
    }

    return extractedEntries;
  }
}