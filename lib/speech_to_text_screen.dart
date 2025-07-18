import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({Key? key}) : super(key: key);

  @override
  State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _transcript = '';
  String _hindiTranscript = '';
  bool _showHindi = false;
  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _transcript = '';
        _showHindi = false;
        _hindiTranscript = '';
      });
      _speech.listen(
        onResult: (result) async {
          setState(() {
            _transcript = result.recognizedWords;
          });
        },
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(seconds: 5),
        localeId: 'en_IN',
        cancelOnError: true,
        partialResults: false,
      );
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _translateToHindi() async {
    if (_transcript.isNotEmpty) {
      var translation = await translator.translate(_transcript, to: 'hi');
      setState(() {
        _hindiTranscript = translation.text;
        _showHindi = true;
      });
    }
  }

  void _resetRecording() {
    setState(() {
      _transcript = '';
      _hindiTranscript = '';
      _showHindi = false;
      _isListening = false;
    });
    _speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech to Text'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Container(
        color: Colors.teal.shade50,
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              'Tap the button and speak for up to 2 minutes.',
              style: TextStyle(fontSize: 18, color: Colors.teal.shade700),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isListening ? Colors.red : Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 40,
                ),
              ),
              onPressed: _isListening ? _stopListening : _startListening,
              child: Text(_isListening ? 'Stop Recording' : 'Start Recording'),
            ),
            const SizedBox(height: 20),
            if (_transcript.isNotEmpty || _showHindi)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.shade100,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _showHindi ? 'Hindi Transcript:' : 'English Transcript:',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _showHindi ? _hindiTranscript : _transcript,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Go Back'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade400,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: _resetRecording,
                          child: const Text('Record Again'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade400,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: _showHindi ? null : _translateToHindi,
                          child: const Text('Show Hindi Version'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
