import 'package:flutter/material.dart';
import 'package:inop_app/provider/teacherauth_provider.dart';
import 'package:inop_app/screens/teacher_home_screen.dart';
import 'package:inop_app/screens/teacherinfo_screen.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../utils/utils.dart';
import '../widgets/custome_button.dart';

class TeacherOtpScreen extends StatefulWidget {
  final String verificationId;

  const TeacherOtpScreen({super.key, required this.verificationId});

  @override
  State<TeacherOtpScreen> createState() => _TeacherOtpScreenState();
}

class _TeacherOtpScreenState extends State<TeacherOtpScreen> {
  String? otpCode;

  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<TeacherAuthProvider>(context, listen: true).isLoading;

    return Scaffold(
        body: SafeArea(
            child: isLoading == true
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  )
                : Center(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 25, horizontal: 30),
                        child: Column(children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Icon(Icons.arrow_back),
                            ),
                          ),
                          Container(
                            width: 280,
                            height: 280,
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.shade50),
                            child: Image.asset("assets/tea1.png"),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Verification",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Enter the OTP sent to your phone number or wait for it to be fetch automatically",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black38,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Pinput(
                            length: 6,
                            showCursor: true,
                            defaultPinTheme: PinTheme(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.black38)),
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                )),
                            onCompleted: (value) {
                              setState(() {
                                otpCode = value;
                              });
                            },
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            child: CustomButton(
                              text: "Verify",
                              onPressed: () {
                                if (otpCode != null) {
                                  verifyOtp(context, otpCode!);
                                } else {
                                  showSnackBar(context, "Enter 6-Digit code");
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Didn't receive any code?",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black38,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Resend New Code",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ])))));
  }

  void verifyOtp(BuildContext context, String userOtp) {
    final teacherauth_provider =
        Provider.of<TeacherAuthProvider>(context, listen: false);

    teacherauth_provider.verifyOtp(
        context: context,
        verificationId: widget.verificationId,
        userOtp: userOtp,
        onSuccess: () {
          teacherauth_provider.checkExistingUser().then((value) async {
            if (value == true) {
              teacherauth_provider.getDataFromFirestore().then((value) =>
                  teacherauth_provider.saveUserDataLocally().then((value) =>
                      teacherauth_provider
                          .setSignIn()
                          .then((value) => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TeacherHomeScreen(),
                              ),
                              (route) => false))));
            } else {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TeacherInfoScreen()),
                  (route) => false);
            }
          });
        });
  }
}
