import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inop_app/provider/teacherauth_provider.dart';
import 'package:inop_app/screens/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pdf_text/pdf_text.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => TeacherHomeScreenState();
}

class TeacherHomeScreenState extends State<TeacherHomeScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  FlutterTts tts = FlutterTts();
  List<Map<String, dynamic>> pdfData = [];

  Future<String> uploadPdf(String fileName, File file) async {
    final reference =
        FirebaseStorage.instance.ref().child("pdfs/$fileName.pdf");

    final uploadTask = reference.putFile(file);

    await uploadTask.whenComplete(() {});

    final downloadUrl = await reference.getDownloadURL();

    return downloadUrl;
  }

  void pickFile() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["pdf", "doc"],
    );

    if (pickedFile != null) {
      String fileName = pickedFile.files[0].name;

      File file = File(pickedFile.files[0].path!);
      final downloadUrl = await uploadPdf(fileName, file);

      _firebaseFirestore.collection("pdfs").add({
        "name": fileName,
        "url": downloadUrl,
      });
      // ignore: avoid_print
      print("Pdf uploaded Successfully");
    }
  }

  void getAllPdf() async {
    final results = await _firebaseFirestore.collection("pdfs").get();

    pdfData = results.docs.map((e) => e.data()).toList();
    // pdfData = results.docs.map((snapshot) => snapshot.data()).toList();

    setState(() {});
  }

  void speak(String text) async {
    String fullText = "You clicked " + text;
    await tts.speak(fullText);
  }

  @override
  void initState() {
    super.initState();
    getAllPdf();
  }

  @override
  Widget build(BuildContext context) {
    final teacherauth_provider =
        Provider.of<TeacherAuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black38,
        title: new Text("INOP LEARN"),
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
      ),
      body: GridView.builder(
        itemCount: pdfData.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                String pdfName = pdfData[index]['name'];
                speak(pdfName);
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) =>
                          PdfViewerScreen(pdfUrl: pdfData[index]['url'])),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset(
                      "assets/pdf2.png",
                      height: 100,
                      width: 80,
                    ),
                    Text(
                      pdfData[index]['name'],
                      style: const TextStyle(
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        // child: const Icon(Icons.upload_file),
        onPressed: pickFile,
        label: const Text("Upload Course Material"),
        backgroundColor: Colors.black38,
      ),
    );
  }
}

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  const PdfViewerScreen({super.key, required this.pdfUrl});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  PDFDocument? document;
  String? text;
  FlutterTts tts = FlutterTts();

  //  final PDFController pdfController = PDFController(document: document!);

  void speak() async {
    await tts.speak(text!);
  }

  void stop() async {
    await tts.stop();
  }

  Future<void> extractText() async {
    PDFDoc doc = await PDFDoc.fromURL(widget.pdfUrl);
    final text = await doc.text;
    setState(() {
      this.text = text;
      print(text);
    });
  }

  void initialisePdf() async {
    document = await PDFDocument.fromURL(widget.pdfUrl);
    await extractText();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initialisePdf();
    tts = FlutterTts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("INOP LEARN"),
        backgroundColor: Colors.black26,
        actions: [
          IconButton(
              onPressed: () {
                // stop
                stop();
              },
              icon: const Icon(Icons.stop)),
          IconButton(
              onPressed: () {
                // start
                speak();
              },
              icon: const Icon(Icons.mic)),
        ],
      ),
      body: document != null
          ? PDFViewer(
              document: document!,
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}



// backgroundColor: Colors.black,
//         title: new Text("INOP LEARN"),
//         actions: [
//           IconButton(
//             onPressed: () {
//               teacherauth_provider.userSignOut().then(
//                     (value) => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const WelcomeScreen(),
//                       ),
//                     ),
//                   );
//             },
//             icon: const Icon(Icons.exit_to_app),
//           ),
//         ],
