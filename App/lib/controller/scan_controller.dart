// ignore_for_file: avoid_print, await_only_futures, prefer_typing_uninitialized_variables

import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    initCamera();
    initTFLite();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
    Tflite.close();
  }

  late CameraController cameraController;

  late List<CameraDescription> cameras;

  var isCameraInitialized = false.obs;
  var cameraCount = 0;

  var list = [];
  var x, y, w, h = 0.0;
  var label = "";

  var detector;

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      cameraController = await CameraController(
        cameras[0],
        ResolutionPreset.max,
      );
      await cameraController.initialize().then((value) {
        cameraController.startImageStream((image) {
          cameraCount++;
          if (cameraCount % 10 == 0) {
            cameraCount = 0;
            objectDetector(image);
          }
          update();
        });
      });
      isCameraInitialized(true);
      update();
    } else {
      print("Permission Denied");
    }
  }

  initTFLite() async {
    await Tflite.loadModel(
      model: "assets/ai/model.tflite",
      labels: "assets/ai/labels.txt",
      isAsset: true,
      numThreads: 1,
      useGpuDelegate: false,
    );
  }

  objectDetector(CameraImage image) async {
    detector = await Tflite.detectObjectOnFrame(
      bytesList: image.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResultsPerClass: 1,
      threshold: 0.4,
      rotation: 90,
    );

    if (detector != null) {
      var ourDetectedObject = detector.first;
      if (ourDetectedObject["confidenceInClass"] * 100 > 45) {
        x = ourDetectedObject["rect"]["x"];
        y = ourDetectedObject["rect"]["y"];
        w = ourDetectedObject["rect"]["w"];
        h = ourDetectedObject["rect"]["h"];
        label = ourDetectedObject["detectedClass"].toString();
      }
      update();
    }
  }
}
