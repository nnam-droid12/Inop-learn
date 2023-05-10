import 'package:flutter/material.dart';
import 'package:inop_app/provider/auth_provider.dart';
import 'package:inop_app/screens/upload_pdf_screen.dart';
import 'package:inop_app/screens/welcome_screen.dart';
import 'package:inop_app/widgets/custome_button.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth_provider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          title: const Text("INOP LEARN"),
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              onPressed: () {
                auth_provider.userSignOut().then(
                      (value) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WelcomeScreen(),
                        ),
                      ),
                    );
              },
              icon: const Icon(Icons.exit_to_app),
            ),
          ],
        ),
        body: Container(
          child: auth_provider.userModel != null
              ? Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: CircleAvatar(
                        backgroundColor: Colors.black,
                        backgroundImage:
                            NetworkImage(auth_provider.userModel!.profilePic),
                        radius: 50,
                      ),
                      // const SizedBox(height: 20),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        auth_provider.userModel!.name,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: CustomButton(
                        text: 'Start Reading',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UploadMaterial(),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                )
              : CircularProgressIndicator(),
        ));
  }
}
