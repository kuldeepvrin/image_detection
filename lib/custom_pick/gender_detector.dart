import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img_lib;
import 'package:tflite_flutter/tflite_flutter.dart';

class GenderDetector {
  Interpreter? _interpreter;
  List<String>? _labels;
  bool _isModelLoaded = false;

  static const int _inputSize = 224;

  GenderDetector() {
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/gender_model.tflite');
      String labelsData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsData.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      _isModelLoaded = true;
      print('Model and labels loaded successfully!');
    } catch (e) {
      print('Failed to load model or labels: $e');
      _isModelLoaded = false;
    }
  }

  void dispose() {
    _interpreter?.close();
  }

  Future<String> detectGender(File imageFile) async {
    if (!_isModelLoaded) {
      return 'Error: Model not loaded.';
    }

    final imageBytes = await imageFile.readAsBytes();
    img_lib.Image? originalImage = img_lib.decodeImage(imageBytes);

    if (originalImage == null) {
      return 'Error: Failed to decode image.';
    }

    // Preprocess the image to match the model's input
    img_lib.Image resizedImage = img_lib.copyResize(originalImage, width: _inputSize, height: _inputSize);

    // Convert to Uint8List for a standard model
    Uint8List inputBytes = Uint8List(1 * _inputSize * _inputSize * 3);
    int pixelIndex = 0;

    // for (int y = 0; y < _inputSize; y++) {
    //   for (int x = 0; x < _inputSize; x++) {
    //     final pixel = resizedImage.getPixel(x, y);
    //     inputBytes[pixelIndex++] = img_lib.getRed(pixel);
    //     inputBytes[pixelIndex++] = img_lib.getGreen(pixel);
    //     inputBytes[pixelIndex++] = img_lib.getBlue(pixel);
    //   }
    // }
    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = resizedImage.getPixel(x, y);

        inputBytes[pixelIndex++] = pixel.r.toInt();
        inputBytes[pixelIndex++] = pixel.g.toInt();
        inputBytes[pixelIndex++] = pixel.b.toInt();
      }
    }

    final input = inputBytes.reshape([1, _inputSize, _inputSize, 3]);
    var output = List<double>.filled(1 * _labels!.length, 0).reshape([1, _labels!.length]);

    _interpreter!.run(input, output);

    List<double> probabilities = output[0];
    int predictedIndex = 0;
    double maxProbability = 0.0;
    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxProbability) {
        maxProbability = probabilities[i];
        predictedIndex = i;
      }
    }

    String detectedGender = _labels![predictedIndex];
    double confidence = maxProbability * 100;

    return '$detectedGender (${confidence.toStringAsFixed(2)}%)';
  }
}
