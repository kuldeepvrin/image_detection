// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';
//
// class GenderDetectionHome extends StatefulWidget {
//   @override
//   _GenderDetectionHomeState createState() => _GenderDetectionHomeState();
// }
//
// class _GenderDetectionHomeState extends State<GenderDetectionHome> {
//   File? _image;
//   String _result = "No image selected";
//   late Interpreter _interpreter;
//   final picker = ImagePicker();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadModel();
//   }
//
//   Future<void> _loadModel() async {
//     try {
//       _interpreter = await Interpreter.fromAsset('gender_classification.tflite');
//     } catch (e) {
//       print("Error loading model: $e");
//     }
//   }
//
//   Future<void> _pickImage() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile == null) return;
//
//     setState(() {
//       _image = File(pickedFile.path);
//       _result = "Detecting...";
//     });
//
//     await _predictGender(_image!);
//   }
//
//   Future<void> _predictGender(File imageFile) async {
//     // Preprocess the image for the model (depends on your model input requirements)
//     // Example assumes 224x224 RGB input and float32 normalization [0..1]
//
//     var imageProcessor = ImageProcessorBuilder().add(ResizeOp(224, 224, ResizeMethod.nearestneighbour)).build();
//
//     TensorImage inputImage = TensorImage.fromFile(imageFile);
//     inputImage = imageProcessor.process(inputImage);
//
//     // Create input and output tensors
//     var input = inputImage.buffer.asFloat32List();
//     var output = List.filled(2, 0.0).reshape([1, 2]);
//
//     try {
//       _interpreter.run(input.reshape([1, 224, 224, 3]), output);
//
//       double maleProb = output[0][0];
//       double femaleProb = output[0][1];
//
//       String gender = maleProb > femaleProb ? "Male" : "Female";
//       double confidence = maleProb > femaleProb ? maleProb : femaleProb;
//
//       setState(() {
//         _result = '$gender detected with ${(confidence * 100).toStringAsFixed(2)}% confidence';
//       });
//     } catch (e) {
//       setState(() {
//         _result = "Error during gender detection: $e";
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _interpreter.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Gender Detection from Image')),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _image == null ? Text('Pick an image to detect gender') : Image.file(_image!, height: 300),
//               SizedBox(height: 20),
//               Text(_result, style: TextStyle(fontSize: 18)),
//               SizedBox(height: 20),
//               ElevatedButton(onPressed: _pickImage, child: Text('Pick Image')),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
