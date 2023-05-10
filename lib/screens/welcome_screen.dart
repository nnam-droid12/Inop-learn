import 'package:flutter/material.dart';
import 'package:inop_app/widgets/custome_button.dart';
import 'package:inop_app/screens/register_screen.dart';
import 'package:inop_app/provider/auth_provider.dart';
import 'package:inop_app/provider/teacherauth_provider.dart';
import 'package:provider/provider.dart';
import 'package:inop_app/screens/user_home_screen.dart';
import 'package:inop_app/screens/teacher_home_screen.dart';
import 'package:alan_voice/alan_voice.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
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
    ))));
  }

  _WelcomeScreenState() {
    /// Init Alan Button with project key from Alan Studio
    AlanVoice.addButton(
        "25820db329e47dd62520a9005ad751b82e956eca572e1d8b807a3e2338fdd0dc/stage");

    /// Handle commands from Alan Studio
    AlanVoice.onCommand.add((command) {
      debugPrint("got new command ${command.toString()}");
    });
  }
}
