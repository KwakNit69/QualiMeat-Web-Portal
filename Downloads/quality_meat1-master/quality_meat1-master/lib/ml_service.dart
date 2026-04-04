import 'dart:typed_data';
import 'package:flutter_vision/flutter_vision.dart';

class MLService {
  static final FlutterVision vision = FlutterVision();
  static bool isLoaded = false;

  static Future<void> loadModel() async {
    if (isLoaded) return;

    await vision.loadYoloModel(
      labels: 'assets/labels.txt',
      modelPath: 'assets/best.tflite',
      modelVersion: "yolov8",
      quantization: false,
      numThreads: 1,
      useGpu: false,
    );

    isLoaded = true;
  }

  static Future<List<Map<String, dynamic>>> runAnalysis(
      Uint8List bytes,
      ) async {
    final results = await vision.yoloOnImage(
      bytesList: bytes,
      imageHeight: 640,
      imageWidth: 640,
      iouThreshold: 0.4,
      confThreshold: 0.4,
      classThreshold: 0.5,
    );

    return List<Map<String, dynamic>>.from(results);
  }

  static Future<void> closeModel() async {
    await vision.closeYoloModel();
    isLoaded = false;
  }
}