import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'dart:ui';

class ToneAnalyzerScreen extends StatefulWidget {
  const ToneAnalyzerScreen({Key? key}) : super(key: key);

  @override
  State<ToneAnalyzerScreen> createState() => _ToneAnalyzerScreenState();
}

class _ToneAnalyzerScreenState extends State<ToneAnalyzerScreen> {
  File? _image;
  Uint8List? _webImage;
  String _extractedText = '';
  String _toneResult = '';
  bool _loading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _image = null;
          _extractedText = '';
          _toneResult = '';
        });
        await _analyzeImageWeb(bytes);
      } else {
        setState(() {
          _image = File(pickedFile.path);
          _webImage = null;
          _extractedText = '';
          _toneResult = '';
        });
        await _analyzeImage(_image!);
      }
    }
  }

  Future<void> _analyzeImage(File image) async {
    setState(() {
      _loading = true;
    });
    final inputImage = InputImage.fromFile(image);
    final textDetector = GoogleMlKit.vision.textDetector();
    final RecognizedText recognizedText = await textDetector.processImage(
      inputImage,
    );
    await textDetector.close();
    setState(() {
      _extractedText = recognizedText.text;
    });
    await _analyzeTone(_extractedText);
    setState(() {
      _loading = false;
    });
  }

  Future<void> _analyzeImageWeb(Uint8List bytes) async {
    setState(() {
      _loading = true;
    });

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: const Size(100, 100),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: 100,
      ),
    );
    // Note: Metadata is not used in web, but required for consistency
    final textDetector = GoogleMlKit.vision.textDetector();
    final RecognizedText recognizedText = await textDetector.processImage(
      inputImage,
    );
    await textDetector.close();
    setState(() {
      _extractedText = recognizedText.text;
    });
    await _analyzeTone(_extractedText);
    setState(() {
      _loading = false;
    });
  }

  Future<void> _analyzeTone(String text) async {
    // Simple rule-based tone analysis for demonstration
    String lower = text.toLowerCase();
    String tone = '';
    if (lower.contains('wtf') ||
        lower.contains('angry') ||
        lower.contains('mad')) {
      tone = 'Aggressive/Shocked';
    } else if (lower.contains('happy') ||
        lower.contains('great') ||
        lower.contains('awesome')) {
      tone = 'Positive';
    } else if (lower.contains('sad') ||
        lower.contains('sorry') ||
        lower.contains('upset')) {
      tone = 'Negative';
    } else {
      tone = 'Neutral or Context-dependent';
    }
    // Contextual brief
    String brief = '';
    if (tone == 'Aggressive/Shocked') {
      brief =
          'The chat contains phrases expressing shock or aggression. Context may indicate surprise or anger.';
    } else if (tone == 'Positive') {
      brief =
          'The chat is generally positive, with expressions of happiness or approval.';
    } else if (tone == 'Negative') {
      brief =
          'The chat contains negative emotions, such as sadness or apology.';
    } else {
      brief = 'The chat tone is neutral or requires more context to interpret.';
    }
    setState(() {
      _toneResult = 'Tone: $tone\n\nBrief: $brief';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyze Tone'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _pickImage,
              child: const Text('Upload Chat Screenshot'),
            ),
            const SizedBox(height: 20),
            if (_image != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal),
                ),
                child: Image.file(_image!),
              ),
            if (_webImage != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal),
                ),
                child: Image.memory(_webImage!),
              ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_extractedText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'Extracted Text:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            if (_extractedText.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.grey.shade200,
                child: Text(_extractedText),
              ),
            if (_toneResult.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _toneResult,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

extension on Vision {
  textDetector() {}
}
