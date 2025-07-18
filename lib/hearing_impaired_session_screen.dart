import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'speech_to_text_screen.dart';
import 'tone_analyzer_screen.dart';

class HearingImpairedSessionScreen extends StatefulWidget {
  const HearingImpairedSessionScreen({Key? key}) : super(key: key);

  @override
  State<HearingImpairedSessionScreen> createState() =>
      _HearingImpairedSessionScreenState();
}

class _HearingImpairedSessionScreenState
    extends State<HearingImpairedSessionScreen> {
  bool _callAlertActive = false;
  late stt.SpeechToText _speech;
  final String _targetName = 'sam';
  String _statusText = '';
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startCallAlert() async {
    try {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _callAlertActive = true;
          _statusText = 'Listening for "$_targetName"...';
        });
        _speech.listen(
          onResult: (result) async {
            String recognized = result.recognizedWords.toLowerCase().replaceAll(
              RegExp(r'[^a-z ]'),
              ' ',
            );
            // Use regex for word boundary match
            if (RegExp(r'\b' + _targetName + r'\b').hasMatch(recognized)) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: const Text('"Sam" detected within 50cm radius!'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Okay'),
                      ),
                    ],
                  );
                },
              );
              await _speech.stop();
              setState(() {
                _callAlertActive = false;
                _statusText = 'Detection complete.';
              });
            } else {
              setState(() {
                _statusText = 'Listening for "$_targetName"...';
              });
            }
          },
          listenFor: const Duration(minutes: 2),
          pauseFor: const Duration(seconds: 5),
          localeId: 'en_IN',
          cancelOnError: true,
          partialResults: true,
          onSoundLevelChange: (level) {},
        );
      } else {
        setState(() {
          _statusText = 'Speech recognition unavailable.';
        });
      }
    } catch (e) {
      setState(() {
        _callAlertActive = false;
        _statusText = 'Error: ' + e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hearing Impaired Session'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Container(
        color: Colors.teal.shade50,
        child: Column(
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 40,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SpeechToTextScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Speech to Text',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 40,
                      ),
                    ),
                    onPressed: _callAlertActive ? null : _startCallAlert,
                    child: Text(
                      _callAlertActive
                          ? 'Listening for "Sam"...'
                          : 'Call Alert',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (_statusText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _statusText,
                        style: TextStyle(
                          color: _statusText.startsWith('Error')
                              ? Colors.red
                              : Colors.teal.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 40,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ToneAnalyzerScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Analyze Tone',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
