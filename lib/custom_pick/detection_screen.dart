import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'gender_detector.dart'; // Your detector class

class GenderDetectionScreen extends StatefulWidget {
  const GenderDetectionScreen({super.key});

  @override
  State<GenderDetectionScreen> createState() => _GenderDetectionScreenState();
}

class _GenderDetectionScreenState extends State<GenderDetectionScreen> {
  File? _image;
  String _detectionResult = 'Pick an image to detect gender';
  // bool _isLoadingImage = false;
  final GenderDetector _detector = GenderDetector();
  bool _isLoadingModel = true;

  @override
  void initState() {
    super.initState();
    _initModel();
  }

  Future<void> _initModel() async {
    await _detector.loadModel();
    setState(() {
      _isLoadingModel = false;
    });
  }

  @override
  void dispose() {
    _detector.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isLoadingModel) {
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _detectionResult = 'Detecting gender...';
      });

      String result = await _detector.detectGender(_image!);
      setState(() {
        _detectionResult = 'Detected: $result';
      });
    } else {
      setState(() {
        _detectionResult = 'No image selected.';
        _image = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gender Detector 🧐'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Display the picked image
              _image == null
                  ? const Text('Image will appear here.')
                  : Image.file(_image!, height: 200, width: 200, fit: BoxFit.cover),
              const SizedBox(height: 30),

              // Display the detection result
              Text(
                _detectionResult,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Buttons to pick images
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoadingModel ? null : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Pick from Gallery'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue, foregroundColor: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoadingModel ? null : () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
