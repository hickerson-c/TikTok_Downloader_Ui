import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;

/// Removes invalid characters from filenames for Windows/macOS compatibility
String sanitizeFileName(String filename) {
  return filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_'); // Replace invalid characters with "_"
}

class DownloadManager {
  /// Downloads a TikTok video and saves it with a unique filename
  static Future<String> downloadTikTokVideo(String url, {String? customName}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      
      // Generate a dynamic filename and sanitize it
      String rawFilename = customName ?? "tiktok_${DateTime.now().millisecondsSinceEpoch}.mp4";
      String filename = sanitizeFileName(rawFilename); // Ensure it's Windows-safe
      String savePath = '${directory.path}/$filename';

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
      if (dioError.response != null) {import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;

/// Removes invalid characters from filenames for Windows/macOS compatibility
String sanitizeFileName(String filename) {
  return filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_'); // Replace invalid characters with "_"
}

class DownloadManager {
  /// Downloads a TikTok video and saves it with a unique filename
  static Future<String> downloadTikTokVideo(String url, {String? customName}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      
      // Generate a dynamic filename and sanitize it
      String rawFilename = customName ?? "tiktok_${DateTime.now().millisecondsSinceEpoch}.mp4";
      String filename = sanitizeFileName(rawFilename); // Ensure it's Windows-safe
      String savePath = '${directory.path}/$filename';

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
}        developer.log("⚠️ HTTP Status Code: ${dioError.response?.statusCode}");
      }
      return "";
    } catch (e) {
      developer.log("\n❌ Unknown Download Error: $e");
      return "";
    }
  }
}