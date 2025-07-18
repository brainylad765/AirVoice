import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:vibration/vibration.dart';
import 'hearing_impaired_session_screen.dart';
import 'object_detection_screen.dart';
// Speech-to-Text and Call Alert engine
// ...existing code...

final FlutterTts flutterTts = FlutterTts();
void main() => runApp(const AIBledApp());

class AIBledApp extends StatelessWidget {
  const AIBledApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI.Bled',
      theme: ThemeData(
        fontFamily: 'Montserrat',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigateToDetail(BuildContext context, String option, int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) =>
            DetailScreen(option: option),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          Offset begin = (index == 0 || index == 2)
              ? const Offset(-1.0, 0.0)
              : const Offset(1.0, 0.0);
          return SlideTransition(
            position: animation.drive(
              Tween(
                begin: begin,
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> options = [
      {'icon': Icons.remove_red_eye, 'label': 'Visually Impaired'},
      {'icon': Icons.hearing, 'label': 'Hearing Impaired'},
      {'icon': Icons.accessible, 'label': 'Physically Challenged'},
      {'icon': Icons.text_fields, 'label': 'Dyslexic Support'},
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB2F3E6), Color(0xFFE0FCFA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade700,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'AI.Bled',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 3 / 2,
                      children: List.generate(
                        options.length,
                        (index) => FlipCardButton(
                          icon: options[index]['icon'],
                          text: options[index]['label'],
                          onTap: () => _navigateToDetail(
                            context,
                            options[index]['label'],
                            index,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.teal.shade700,
                child: const Icon(Icons.menu),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (ctx) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text("Profile"),
                          onTap: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Profile clicked!")),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.settings),
                          title: const Text("General Settings"),
                          onTap: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Settings clicked!"),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlipCardButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const FlipCardButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  State<FlipCardButton> createState() => _FlipCardButtonState();
}

class _FlipCardButtonState extends State<FlipCardButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _flip() {
    if (isFront) {
      _controller.forward().then((_) => widget.onTap());
    } else {
      _controller.reverse();
    }
    isFront = !isFront;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);
          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: _controller.value <= 0.5 ? _buildFront() : _buildBack(),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return _buildCard(widget.icon, widget.text);
  }

  Widget _buildBack() {
    return _buildCard(Icons.check_circle, "Open");
  }

  Widget _buildCard(IconData icon, String text) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF009688), Color(0xFF4DB6AC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4)),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 42),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class DetailScreen extends StatefulWidget {
  final String option;

  const DetailScreen({super.key, required this.option});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isInstalled = false;
  bool introDone = false;

  // ✅ 1. Declare TTS object
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
  }

  List<Map<String, String>> getFeatures() {
    switch (widget.option) {
      case 'Visually Impaired':
        return [
          {
            'title': 'Object Detection',
            'subtitle':
                'Detect objects in your surroundings using your camera.',
          },
          {
            'title': 'Text-to-Speech',
            'subtitle': 'Read out text from images or documents.',
          },
        ];
      case 'Hearing Impaired':
        return [
          {
            'title': 'Speech-to-Text',
            'subtitle': 'Convert spoken words to text in real-time.',
          },
          {
            'title': 'Call Alert',
            'subtitle': 'Get notified when someone calls your name.',
          },
          {
            'title': 'Speech Tone Analyzer',
            'subtitle': 'Analyze the tone of speech for better understanding.',
          },
        ];
      case 'Physically Challenged':
        return [
          {
            'title': 'Accessibility Controls',
            'subtitle': 'Easy access to controls for physical challenges.',
          },
          {
            'title': 'Voice Commands',
            'subtitle': 'Control the app using your voice.',
          },
        ];
      case 'Dyslexic Support':
        return [
          {
            'title': 'Text Formatting',
            'subtitle': 'Format text for easier reading.',
          },
          {
            'title': 'Speech Assistance',
            'subtitle': 'Listen to text read aloud for better comprehension.',
          },
        ];
      default:
        return [];
    }
  }

  String getSubtitle() {
    switch (widget.option) {
      case 'Visually Impaired':
        return 'AI-powered visual assistance and navigation.';
      case 'Hearing Impaired':
        return 'Sound recognition and communication tools.';
      case 'Physically Challenged':
        return 'AI-powered mobility and control assistance.';
      case 'Dyslexic Support':
        return 'Reading and learning assistance tools.';
      default:
        return '';
    }
  }

  // ...existing code...
  @override
  Widget build(BuildContext context) {
    final features = getFeatures();
    final subtitle = getSubtitle();

    // If Hearing Impaired and introDone, show new window with 3 options
    if (widget.option == 'Hearing Impaired' && introDone) {
      return const HearingImpairedSessionScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.option),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Container(
        color: Colors.teal.shade50,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Icon(
                widget.option == 'Visually Impaired'
                    ? Icons.remove_red_eye
                    : widget.option == 'Hearing Impaired'
                    ? Icons.hearing
                    : widget.option == 'Physically Challenged'
                    ? Icons.accessible
                    : Icons.text_fields,
                size: 60,
                color: Colors.teal.shade700,
              ),
              const SizedBox(height: 12),
              Text(
                widget.option,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.teal.shade700),
              ),
              const SizedBox(height: 20),
              ...features.map((feature) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
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
                        feature['title']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feature['subtitle']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInstalled
                      ? Colors.grey
                      : Colors.teal.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 40,
                  ),
                ),
                onPressed: isInstalled
                    ? null
                    : () {
                        setState(() {
                          isInstalled = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Package Installed!')),
                        );
                        if (widget.option == 'Hearing Impaired') {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "श्रवण बाधित मॉड्यूल में आपका स्वागत है, यह मॉड्यूल श्रवण बाधित व्यक्तियों की सहायता के लिए बनाया गया है और इसमें speech to text, call alert और speech tone analyzer शामिल हैं, इस मॉड्यूल का उपयोग करने के लिए, *हरे रंग का* start session बटन पर क्लिक करें और इसे अभी के लिए रद्द करने के लिए, *back* बटन पर क्लिक करें|| "
                                        "Welcome to Hearing impaired module, this module is designed to assist the hearing impaired individuals and contains speech to text engine, call alert and speech tone analyzer, to use this module, click the *green colored* start session button and to cancel this for now, click on the *back* button ",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.green.shade400,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 12,
                                                  ),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              setState(() {
                                                introDone = true;
                                              });
                                            },
                                            child: const Text(
                                              'Start Session',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          OutlinedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Back'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                child: Text(
                  isInstalled ? 'Package Installed' : 'Install Package',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInstalled
                      ? Colors.teal.shade700
                      : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 40,
                  ),
                ),
                onPressed: isInstalled
                    ? () {
                        if (widget.option == 'Visually Impaired') {
                          if (!introDone) {
                            // FIRST PRESS — Speak intro
                            _speakHindiEnglish(
                              "दृष्टिबाधित मॉड्यूल में आपका स्वागत है। "
                                  "यह मॉड्यूल दृष्टिहीन व्यक्तियों की सहायता के लिए डिज़ाइन किया गया है और इसमें वस्तु पहचान और पाठ से भाषण सुविधाएँ शामिल हैं। "
                                  "इस मॉड्यूल का उपयोग करने के लिए, कृपया फिर से 'Start Session' बटन पर क्लिक करें। ",
                              "Welcome to Vision Impaired Module. "
                                  "This module is designed to assist visually impaired individuals and contains object detection and text-to-speech features. "
                                  "To use this module now, so click again on the start session button.",
                            );
                            setState(() {
                              introDone = true;
                            });
                          } else {
                            // SECOND PRESS — Go to ObjectDetectionScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ObjectDetectionScreen(),
                              ),
                            );
                          }
                        } else if (widget.option == 'Hearing Impaired') {
                          // Always open HearingImpairedSessionScreen when installed and Start Session is pressed
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const HearingImpairedSessionScreen(),
                            ),
                          );
                        } else {
                          // For other modules, show a message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Object Detection is only available for the Visually Impaired module.',
                              ),
                            ),
                          );
                        }
                      }
                    : null,
                child: const Text(
                  'Start Session',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
  // ...existing code...
  // ...existing code...

  // ✅ 2. Create the speakHindi method
  Future<void> _speakHindi(String hindiText, String englishText) async {
    // Try setting Hindi language and check result
    var hindiResult = await flutterTts.setLanguage("hi-IN");
    if (hindiResult == 1 || hindiResult == true) {
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(1.0);
      await flutterTts.speak(hindiText);
      await flutterTts.awaitSpeakCompletion(true);
    } else {
      // Fallback: speak in English only
      await flutterTts.speak(englishText);
      return;
    }
    // Speak in English
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.speak(englishText);
  }

  // Define the missing _speakHindiEnglish method
  Future<void> _speakHindiEnglish(String hindiText, String englishText) async {
    await _speakHindi(hindiText, englishText);
  }
}

// ✅ 3. Add the TTS dependency in pubspec.yaml
// ✅ 4. Update the pubspec.yaml file to include flutter_tts dependency
// ✅ 5. Ensure the TTS functionality is tested in the DetailScreen
// ✅ 6. Ensure the TTS functionality is triggered in the Start Session button
// ✅ 7. Ensure the TTS functionality is only available when the package is installed
// ✅ 8. Ensure the TTS functionality is not available when the package is not installed
// ✅ 9. Ensure the TTS functionality is only available in the Hearing Impaired module
// ✅ 10. Ensure the TTS functionality is not available in other modules
// ✅ 11. Ensure the TTS functionality is only available when the package is installed

// Dummy ObjectDetectionScreen implementation to resolve the error.
