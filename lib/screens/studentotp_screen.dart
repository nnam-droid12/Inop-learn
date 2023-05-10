import 'package:flutter/material.dart';
import 'package:inop_app/provider/auth_provider.dart';
import 'package:inop_app/screens/user_home_screen.dart';
import 'package:inop_app/screens/studentinfo_screen.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import 'package:inop_app/utils/utils.dart';
import 'package:inop_app/widgets/custome_button.dart';

class StudentOtpScreen extends StatefulWidget {
  final String verificationId;

  const StudentOtpScreen({super.key, required this.verificationId});

  @override
  State<StudentOtpScreen> createState() => _StudentOtpScreenState();
}

class _StudentOtpScreenState extends State<StudentOtpScreen> {
  String? otpCode;

  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;

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
                            child: Image.asset("assets/stu1.jpg"),
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
                          const SizedBox(height: 20),
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
                          const SizedBox(height: 15),
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
    final auth_provider = Provider.of<AuthProvider>(context, listen: false);

    auth_provider.verifyOtp(
        context: context,
        verificationId: widget.verificationId,
        userOtp: userOtp,
        onSuccess: () {
          auth_provider.checkExistingUser().then((value) async {
            if (value == true) {
              auth_provider.getDataFromFirestore().then((value) => auth_provider
                  .saveUserDataLocally()
                  .then((value) => auth_provider
                      .setSignIn()
                      .then((value) => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false))));
            } else {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StudentInfoScreen()),
                  (route) => false);
            }
          });
        });
  }
}
