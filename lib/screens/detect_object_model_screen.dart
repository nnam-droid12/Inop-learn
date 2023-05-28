import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:inop_app/main.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ObjectDetection extends StatefulWidget {
  const ObjectDetection({super.key});

  @override
  State<ObjectDetection> createState() => _ObjectDetectionState();
}

class _ObjectDetectionState extends State<ObjectDetection> {
  bool isworking = false;
  String results = "";
  CameraController? cameraController;
  CameraImage? imgCamera;
  FlutterTts flutterTts = FlutterTts();

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/mobilenet_v1_1.0_224.tflite",
      labels: "assets/mobilenet_v1_1.0_224.txt",
    );
  }

  initCamera() {
    cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      }

      setState(() {
        cameraController!.startImageStream((imageFromStream) => {
              if (!isworking)
                {
                  isworking = true,
                  imgCamera = imageFromStream,
                  runModelOnStreamFrame(),
                }
            });
      });
    });
  }

  runModelOnStreamFrame() async {
    if (imgCamera != null) {
      var recognitions = await Tflite.runModelOnFrame(
        bytesList: imgCamera!.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: imgCamera!.height,
        imageWidth: imgCamera!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 1,
        threshold: 0.1,
        asynch: true,
      );
      results = "";

      recognitions!.forEach((response) {
        results += response['label'] +
            "  " +
            (response['confidence'] as double).toStringAsFixed(2) +
            "\n\n";
      });

      // Speak the results aloud
      await flutterTts.setLanguage('en-US');
      await flutterTts.speak(results);
      setState(() {
        results;
      });

      isworking = false;
    }
  }

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  void dispose() async {
    super.dispose();
    await Tflite.close();
    cameraController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('INOP LEARN'),
          backgroundColor: Colors.black38,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/camera1.png')),
          ),
          child: Column(children: [
            Stack(
              children: [
                Center(
                  child: ElevatedButton(
                      onPressed: () {
                        initCamera();
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 35),
                        height: 270,
                        width: 350,
                        child: imgCamera == null
                            ? Container(
                                color: Colors.black,
                                height: 270,
                                width: 360,
                                child: Icon(Icons.photo_camera_front,
                                    color: Colors.white, size: 60),
                              )
                            : AspectRatio(
                                aspectRatio:
                                    cameraController!.value.aspectRatio,
                                child: CameraPreview(cameraController!),
                              ),
                      )),
                ),
              ],
            ),
            Center(
              child: Container(
                  margin: EdgeInsets.only(top: 55.0),
                  child: SingleChildScrollView(
                    child: Text(results,
                        style: TextStyle(
                          backgroundColor: Colors.black38,
                          fontSize: 30,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center),
                  )),
            ),
          ]),
        ));
  }
}
