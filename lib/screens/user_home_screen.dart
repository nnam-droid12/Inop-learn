import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:inop_app/provider/auth_provider.dart';
import 'package:inop_app/screens/detect_object_model_screen.dart';
import 'package:inop_app/screens/welcome_screen.dart';
// import 'package:inop_app/widgets/custome_button.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_text/pdf_text.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  FlutterTts tts = FlutterTts();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
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

      await FirebaseAnalytics.instance.logEvent(
        name: "pdf_created",
        parameters: {
          "file_name": fileName,
        },
      );
    }
  }

  void getAllPdf() async {
    final results = await _firebaseFirestore.collection("pdfs").get();

    pdfData = results.docs.map((e) => e.data()).toList();

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
    final auth_provider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("INOP LEARN"),
        backgroundColor: Colors.black38,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ObjectDetection()),
              );
            },
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.black12),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            child: Text("Detect", style: const TextStyle(fontSize: 10)),
          ),
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
        label: const Text("Upload Any Material"),
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

  void speak() async {
    await tts.speak(text!);
    await FirebaseAnalytics.instance.logEvent(
      name: 'pdf_audio_playback',
    );
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
