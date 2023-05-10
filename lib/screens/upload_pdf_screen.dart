import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:inop_app/utils/pick_any_document.dart';
import 'package:pdf_text/pdf_text.dart';

class UploadMaterial extends StatefulWidget {
  const UploadMaterial({super.key});

  @override
  State<UploadMaterial> createState() => _UploadMaterialState();
}

class _UploadMaterialState extends State<UploadMaterial> {
  TextEditingController controller = TextEditingController();

  FlutterTts tts = FlutterTts();
  void speak({String? text}) async {
    await tts.speak(text!);
  }

  void stop() async {
    await tts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("INOP LEARN"),
        backgroundColor: Colors.black,
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
                if (controller.text.isNotEmpty) {
                  speak(text: controller.text.trim());
                }
              },
              icon: const Icon(Icons.mic)),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: TextFormField(
            controller: controller,
            maxLines: MediaQuery.of(context).size.height.toInt(),
            decoration: const InputDecoration(label: Text("Enter text...."))),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            pickFileDocument().then((value) async {
              if (value != '') {
                PDFDoc doc = await PDFDoc.fromPath(value);
                final text = await doc.text;
                controller.text = text;
              }
            });
          },
          label: const Text("Upload Course Material"),
          backgroundColor: Colors.black,
          ),
         
    );
  }
}
