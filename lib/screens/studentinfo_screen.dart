import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inop_app/modal/user_modal.dart';
import 'package:inop_app/provider/auth_provider.dart';
import 'package:inop_app/screens/user_home_screen.dart';
import 'package:inop_app/utils/utils.dart';
import 'package:inop_app/widgets/custome_button.dart';
import 'package:provider/provider.dart';

class StudentInfoScreen extends StatefulWidget {
  const StudentInfoScreen({super.key});

  @override
  State<StudentInfoScreen> createState() => _StudentInfoScreenState();
}

class _StudentInfoScreenState extends State<StudentInfoScreen> {
  File? image;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
  }

  void selectedImage() async {
    image = await pickImage(context);
    setState(() {});
  }

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
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(vertical: 25.0, horizontal: 5.0),
              child: Center(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => selectedImage(),
                      child: image == null
                          ? const CircleAvatar(
                              backgroundColor: Colors.black,
                              radius: 50,
                              child: Icon(
                                Icons.account_circle,
                                size: 50,
                                color: Colors.white,
                              ),
                            )
                          : CircleAvatar(
                              backgroundImage: FileImage(image!),
                              radius: 50,
                            ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      margin: const EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          //name
                          textField(
                            hintText: "John Sam",
                            icon: Icons.account_circle,
                            inputType: TextInputType.name,
                            maxLines: 1,
                            controller: nameController,
                          ),
                          //email
                          textField(
                            hintText: "abc@example.com",
                            icon: Icons.email,
                            inputType: TextInputType.emailAddress,
                            maxLines: 1,
                            controller: emailController,
                          ),

                          //bio

                          textField(
                            hintText: "Enter short bio here",
                            icon: Icons.edit,
                            inputType: TextInputType.name,
                            maxLines: 2,
                            controller: bioController,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 1.50,
                        child: CustomButton(
                          text: "Continue",
                          onPressed: () => storeData(),
                        ))
                  ],
                ),
              ),
            ),
    ));
  }

  Widget textField({
    required String hintText,
    required IconData icon,
    required TextInputType inputType,
    required int maxLines,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        cursorColor: Colors.black,
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.black,
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
            color: Colors.transparent),
          ),
          hintText: hintText,
          alignLabelWithHint: true,
          border: InputBorder.none,
          fillColor: Colors.black38,
          filled: true,
        ),
      ),
    );
  }

  // Store Data
  void storeData() async {
    final auth_provider = Provider.of<AuthProvider>(context, listen: false);
    UserModel userModel = UserModel(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      bio: bioController.text.trim(),
      profilePic: "",
      createdAt: "",
      phoneNumber: "",
      uid: "",
    );
    if (image != null) {
      auth_provider.saveUserDataToFirebase(
          context: context,
          userModel: userModel,
          profilePic: image!,
          onSuccess: () {
            auth_provider.saveUserDataLocally().then((value) => 
            auth_provider.setSignIn().then((value) => 
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder:  (context) => const HomeScreen(),
              ),
              (route) => false),
              ),
              );
          });
    } else {
      showSnackBar(context, "Please upload your profile photo");
    }
  }
}
