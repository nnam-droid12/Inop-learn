import 'package:flutter/material.dart';
import 'package:inop_app/provider/teacherauth_provider.dart';
import 'package:inop_app/screens/welcome_screen.dart';
import 'package:inop_app/utils/document_utils.dart';
import 'package:provider/provider.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => TeacherHomeScreenState();
}

class TeacherHomeScreenState extends State<TeacherHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final teacherauth_provider =
        Provider.of<TeacherAuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: new Text("INOP APP"),
        actions: [
          IconButton(
            onPressed: () {
              teacherauth_provider.userSignOut().then(
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
        leading: new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Material(
            child: Image.asset(
              "dev_assets/inop-learn-logo.png",
              fit: BoxFit.fill,
            ),

            shape: new CircleBorder(
                //  Image.asset("dev_assets/inop-learn-logo.png")
                ),
            // ,
          ),
        ),
      ),
      body: Padding(
          padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Course Materials",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Column(
                    children: Document.doc_list
                        .map((doc) => ListTile(
                              title: Text(
                                doc.doc_title!,
                                style: TextStyle(fontSize: 32),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text("${doc.page_num!} Pages"),
                              trailing: Text(
                                doc.doc_date!,
                                style: TextStyle(fontSize: 15),
                              ),
                              leading: Icon(
                                Icons.picture_as_pdf,
                                color: Colors.blue,
                                size: 32.0,
                              ),
                            ))
                        .toList(),
                  )
                ]),
          )),
    );
  }
}
