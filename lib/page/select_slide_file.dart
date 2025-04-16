import 'package:flutter/material.dart';
import 'package:lap26_3/page/home.dart';

class SelectSlideFilePage extends StatelessWidget {
  final List<String> availableJsonFiles = [
    'assets/testDefaul.json',
    'assets/sample1.json',
    'assets/sample2.json',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn file trình chiếu')),
      body: ListView.builder(
        itemCount: availableJsonFiles.length,
        itemBuilder: (context, index) {
          String path = availableJsonFiles[index];
          String filename = path.split('/').last;

          return ListTile(
            title: Text(filename),
            leading: const Icon(Icons.insert_drive_file),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HomePage(jsonPath: path),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
