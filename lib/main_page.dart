import 'package:flutter/material.dart';
import 'file_picker_screen.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TikTok Downloader')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text("Select a file to extract TikTok links"),
          SizedBox(height: 20),
          Expanded( // ✅ Wrap in Expanded to fix layout
            child: FilePickerScreen(),
          ),
        ],
      ),
    );
  }
}