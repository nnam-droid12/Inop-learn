import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:inop_app/widgets/custome_button.dart';
import 'package:inop_app/screens/register_screen.dart';
import 'package:inop_app/provider/auth_provider.dart';
import 'package:inop_app/provider/teacherauth_provider.dart';
import 'package:provider/provider.dart';
import 'package:inop_app/screens/user_home_screen.dart';
import 'package:inop_app/screens/teacher_home_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:dialog_flowtter/dialog_flowtter.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late DialogFlowtter dialogFlowtter;
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  final FlutterTts flutterTts = FlutterTts();
  bool _isListening = false;

  List<Map<String, dynamic>> messages = [];

  void startListening() {
    if (!_isListening) {
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
          });
        },
      );
      setState(() {
        _isListening = true;
      });
    }
  }

  void stopListening() {
    if (_isListening) {
      _speechToText.stop();
      setState(() {
        _isListening = false;
      });
    }
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(0.5);

    await flutterTts.speak(text);
  }

  void initSpeechToText() async {
    bool available = await _speechToText.initialize();
    if (available) {
      // Initialization successful
    } else {
      print('Speech recognition not available');
    }
  }

  sendMessage(String text) async {
    if (text.isEmpty) {
      print('Message is empty');
    } else {
      stopListening();
      setState(() {
        addMessage(Message(text: DialogText(text: [text])), true);
      });

      DetectIntentResponse response = await dialogFlowtter.detectIntent(
          queryInput: QueryInput(text: TextInput(text: text)));
      if (response.message == null) return;
      setState(() {
        addMessage(response.message!);
      });
      final responseText = response.message?.text?.text;
      if (responseText != null && responseText.isNotEmpty) {
        speak(responseText[0]);
      }
    }
  }

  addMessage(Message message, [bool isUserMessage = false]) {
    messages.add({'message': message, 'isUserMessage': isUserMessage});
  }

  @override
  void initState() {
    DialogFlowtter.fromFile().then((instance) => dialogFlowtter = instance);
    super.initState();
    initSpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    final auth_provider = Provider.of<AuthProvider>(context, listen: false);
    final teacherauth_provider =
        Provider.of<TeacherAuthProvider>(context, listen: false);
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/image1.jpg",
                height: 300,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Let's get Started",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Never a better time than now to start",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.black38,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Custom button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: CustomButton(
                  onPressed: () {
                    if (auth_provider.isSignedIn == true) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    } else if (teacherauth_provider.isTeacherSignedIn == true) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TeacherHomeScreen(),
                        ),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    }
                  },
                  text: "Get Started",
                ),
              )
            ],
          ),
        )),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black38,
          onPressed: () async {
            startListening();
            await sendMessage(_controller.text);
          },
          child: Icon(
            Icons.mic,
          )),
    );
  }
}



// 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