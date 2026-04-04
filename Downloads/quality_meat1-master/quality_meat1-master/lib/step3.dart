import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_vision/flutter_vision.dart';

class ScannerPage extends StatefulWidget {
  final String selectedCut;
  const ScannerPage({super.key, required this.selectedCut});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  CameraController? _controller;
  late FlutterVision vision;

  bool isAnalyzing = false;
  bool isModelLoaded = false;

  final Color primaryGreen = const Color(0xFF00E676);
  final Color labelColor = const Color(0xFF707B81);

  @override
  void initState() {
    super.initState();
    vision = FlutterVision();
    _setupCamera();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      await vision.loadYoloModel(
        labels: 'assets/labels.txt',
        modelPath: 'assets/best.tflite',
        modelVersion: "yolov8",
        quantization: false,
        numThreads: 1,
        useGpu: false,
      );

      if (mounted) {
        setState(() {
          isModelLoaded = true;
        });
      }
    } catch (e) {
      debugPrint("MODEL ERROR: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Model Load Failed: $e")),
        );
      }
    }
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception("No cameras found");
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("CAMERA ERROR: $e");
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (!isModelLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("AI Model still loading...")),
      );
      return;
    }

    if (isAnalyzing) return;

    setState(() => isAnalyzing = true);

    try {
      if (_controller == null || !_controller!.value.isInitialized) {
        throw Exception("Camera not ready");
      }

      final image = await _controller!.takePicture();
      final bytes = await image.readAsBytes();

      final results = await vision.yoloOnImage(
        bytesList: bytes,
        imageHeight: 640,
        imageWidth: 640,
        iouThreshold: 0.4,
        confThreshold: 0.4,
        classThreshold: 0.5,
      );

      debugPrint("YOLO Results: $results");

      if (!mounted) return;

      String label = "No meat detected";
      double confidence = 0;

      if (results.isNotEmpty) {
        final result = results.first;
        label = result["tag"]?.toString() ?? "Unknown";

        if (result["box"] != null && result["box"].length > 4) {
          confidence =
              ((result["box"][4] ?? 0.0) as num).toDouble() * 100;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Detected: $label (${confidence.toStringAsFixed(1)}%)",
          ),
          backgroundColor: primaryGreen,
        ),
      );
    } catch (e) {
      debugPrint("SCAN ERROR: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Scan failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isAnalyzing = false);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    vision.closeYoloModel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              "NEW INSPECTION",
              style: TextStyle(
                color: labelColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              "Step 3: Scanner (${widget.selectedCut})",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_controller != null &&
                    _controller!.value.isInitialized)
                  SizedBox.expand(
                    child: CameraPreview(_controller!),
                  )
                else
                  const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                      isModelLoaded ? primaryGreen : Colors.red,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                if (isAnalyzing)
                  const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                if (!isModelLoaded)
                  Positioned(
                    top: 20,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.black54,
                      child: const Text(
                        "Loading AI Model...",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Align ${widget.selectedCut} within the frame",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _captureAndAnalyze,
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isModelLoaded
                            ? primaryGreen
                            : Colors.grey,
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: isModelLoaded
                            ? primaryGreen
                            : Colors.grey,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Ensure high-quality lighting",
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}