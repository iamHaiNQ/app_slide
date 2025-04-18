import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:lap26_3/model/Slide.dart';

import 'home.dart';

class JsonInputPage extends StatefulWidget {
  const JsonInputPage({Key? key}) : super(key: key);

  @override
  _JsonInputPageState createState() => _JsonInputPageState();
}

class _JsonInputPageState extends State<JsonInputPage> {
  final TextEditingController _jsonController = TextEditingController();

  void _playSlides() {
    try {
      final List<dynamic> raw = jsonDecode(_jsonController.text);
      final slides = raw.map((e) => Slide.fromJson(e)).toList();

      if (slides.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No slides found in the JSON array.')),
        );
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => HomePage(slides: slides),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid JSON: $e')),
      );
    }
  }

  Future<void> _pickJsonFile() async {
    try {
      final path = await FlutterDocumentPicker.openDocument(
        params: FlutterDocumentPickerParams(
          allowedFileExtensions: ['json'],
        ),
      );

      if (path != null) {
        final file = File(path);
        final contents = await file.readAsString();
        setState(() {
          _jsonController.text = contents;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paste Slide JSON')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _jsonController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Paste your JSON array of slides here',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _playSlides,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Trình chiếu'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _pickJsonFile,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Chọn file JSON'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
