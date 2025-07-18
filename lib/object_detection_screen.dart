import 'package:flutter/material.dart';

class ObjectDetectionScreen extends StatelessWidget {
  const ObjectDetectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Object Detection'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Center(
        child: Text(
          'Object Detection Screen (Dummy)',
          style: TextStyle(fontSize: 24, color: Colors.teal.shade700),
        ),
      ),
    );
  }
}
