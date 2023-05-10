import 'package:flutter/material.dart';
import 'package:inop_app/modal/teacher_model.dart';
import 'package:inop_app/provider/teacherauth_provider.dart';
import 'package:inop_app/screens/teacher_home_screen.dart';
import 'package:inop_app/utils/utils.dart';
import 'package:inop_app/widgets/custome_button.dart';
import 'package:provider/provider.dart';

class TeacherInfoScreen extends StatefulWidget {
  const TeacherInfoScreen({super.key});

  @override
  State<TeacherInfoScreen> createState() => _TeacherInfoScreenState();
}

class _TeacherInfoScreenState extends State<TeacherInfoScreen> {
  final nameController = TextEditingController();
  final coursetitleController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    coursetitleController.dispose();
  }

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
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(vertical: 25.0, horizontal: 5.0),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      margin: const EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          //name
                          textField(
                            hintText: "Dr Sam",
                            icon: Icons.account_circle,
                            inputType: TextInputType.name,
                            maxLines: 1,
                            controller: nameController,
                          ),
                          //course title
                          textField(
                            hintText: "Course Title",
                            icon: Icons.edit,
                            inputType: TextInputType.name,
                            maxLines: 1,
                            controller: coursetitleController,
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
            borderSide: const BorderSide(color: Colors.transparent),
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
    final teacherauth_provider =
        Provider.of<TeacherAuthProvider>(context, listen: false);
    TeacherModel teacherModel = TeacherModel(
      name: nameController.text.trim(),
      coursetitle: coursetitleController.text.trim(),
      createdAt: "",
      phoneNumber: "",
      uid: "",
    );
   if(nameController.text.isNotEmpty && coursetitleController.text.isNotEmpty){
      teacherauth_provider.saveTeacherDataToFirebase(
        context: context,
        teacherModel: teacherModel,
        onSuccess: () {
          teacherauth_provider.saveUserDataLocally().then((value) =>
              teacherauth_provider.setSignIn().then((value) =>
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TeacherHomeScreen()),
                      (route) => false)));
        });
   }else{
     showSnackBar(context, "Please upload information");
   }
    
  }
}
