import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;
import 'dart:io';

/// Removes invalid characters from filenames for Windows/macOS compatibility
String sanitizeFileName(String filename) {
  return filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_'); // Replace invalid characters
}

/// Generates a unique filename using only the date, avoiding duplicates
Future<String> getUniqueFilename(String directoryPath) async {
  String date = DateTime.now().toIso8601String().split('T')[0]; // Keep only YYYY-MM-DD
  String baseFilename = "tiktok_$date";
  String filename = "$baseFilename.mp4";
  int counter = 1;

  // Check for existing files and increment counter if needed
  while (await File("$directoryPath/$filename").exists()) {
    filename = "$baseFilename\_$counter.mp4"; // Append counter if file exists
    counter++;
  }

  return filename;
}

class DownloadManager {
  /// Downloads a TikTok video and saves it with a unique filename
  static Future<String> downloadTikTokVideo(String url) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      String filename = await getUniqueFilename(directory.path); // Get unique filename
      String savePath = '${directory.path}/$filename';

      // Debug logs to verify filename
      developer.log("✅ Saving file as: $filename");
      developer.log("📁 Save path: $savePath");

      Dio dio = Dio();
      await dio.download(url, savePath, onReceiveProgress: (received, total) {
        if (total != -1) {
          double progress = (received / total) * 100;
          developer.log("📥 Downloading ($filename): ${progress.toStringAsFixed(0)}% (${(received / 1048576).toStringAsFixed(2)} MB)");
        }
      });

      developer.log("\n✅ Download Complete: $savePath");
      return savePath;
    } on DioException catch (dioError) {
      developer.log("\n❌ Dio Network Error: ${dioError.message}");
      if (dioError.response != null) {
        developer.log("⚠️ HTTP Status Code: ${dioError.response?.statusCode}");
      }
      return "";
    } catch (e) {
      developer.log("\n❌ Unknown Download Error: $e");
      return "";
    }
  }
}