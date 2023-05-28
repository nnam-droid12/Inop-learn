import 'package:flutter/material.dart';
import 'package:inop_app/widgets/custome_button.dart';
import 'package:inop_app/screens/register_screen_teacher.dart';
import 'package:country_picker/country_picker.dart';
import 'package:provider/provider.dart';
import 'package:inop_app/provider/auth_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter_tts/flutter_tts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController phoneController = TextEditingController();

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


  Country selectedCountry = Country(
    phoneCode: "234",
    countryCode: "NG",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "Nigeria",
    example: "Nigeria",
    displayName: "Nigeria",
    displayNameNoCountryCode: "NG",
    e164Key: "",
  );

  @override
  Widget build(BuildContext context) {
    phoneController.selection = TextSelection.fromPosition(
      TextPosition(
        offset: phoneController.text.length,
      ),
    );
    return Scaffold(
        body: SingleChildScrollView(
      child: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
        child: Column(
          children: [
            Container(
              width: 280,
              height: 280,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.blue.shade50),
              child: Image.asset(
                "assets/stu1.jpg",
                width: 50,
                height: 50,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Register as a student",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Add your Phone Number, We'll send you a verification code",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black38,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextFormField(
              cursorColor: Colors.black,
              controller: phoneController,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              onChanged: (value) {
                setState(() {
                  phoneController.text = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Enter Phone Number",
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.grey.shade600,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                prefixIcon: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      showCountryPicker(
                          context: context,
                          countryListTheme: const CountryListThemeData(
                              bottomSheetHeight: 550),
                          onSelect: (value) {
                            setState(() {
                              selectedCountry = value;
                            });
                          });
                    },
                    child: Text(
                      "${selectedCountry.flagEmoji} + ${selectedCountry.phoneCode}",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                suffixIcon: phoneController.text.length > 9
                    ? Container(
                        height: 30,
                        width: 30,
                        margin: const EdgeInsets.all(10.0),
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.green),
                        child: const Icon(
                          Icons.done,
                          color: Colors.white,
                          size: 20,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: CustomButton(
                  text: "Register as a student",
                  onPressed: () => sendPhoneNumber()),
            ),
            const SizedBox(height: 10),
            const Text(
              "OR",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              width: 250,
              height: 30,
              child: CustomButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterTeacher()),
                  );
                },
                text: "Are you a teacher?",
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

  void sendPhoneNumber() {
    final auth_provider = Provider.of<AuthProvider>(context, listen: false);
    String phoneNumber = phoneController.text.trim();
    auth_provider.signInWithPhone(
        context, "+${selectedCountry.phoneCode}$phoneNumber");
  }
}
