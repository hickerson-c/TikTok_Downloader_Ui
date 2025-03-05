import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io'; // For platform checks
import 'file_picker_screen.dart'; // ✅ Import the file picker screen


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();  // ✅ Request correct permissions
  runApp(const MyApp());
}

/// ✅ Handles storage permissions based on platform
Future<void> requestPermissions() async {
  if (Platform.isIOS) {
    await Permission.photos.request(); // iOS: Access photo library
  } else {
    await Permission.storage.request(); // Android: Access storage
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TikTok Downloader UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FilePickerScreen(), // ✅ Start with File Picker
    );
  }
}