import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:inop_app/provider/auth_provider.dart';
import 'package:inop_app/provider/teacherauth_provider.dart';
import 'package:inop_app/screens/welcome_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TeacherAuthProvider()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WelcomeScreen(),
        title: "Learning Made Easy",
      ),
    );
  }
}
