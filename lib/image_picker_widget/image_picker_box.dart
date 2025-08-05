import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_detection/image_picker_widget/image_controller.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerBox extends StatefulWidget {
  const ImagePickerBox({super.key});

  @override
  State<ImagePickerBox> createState() => _ImagePickerBoxState();
}

class _ImagePickerBoxState extends State<ImagePickerBox> {
  File? _pickedImage;
  String? _gender;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
        _gender = null;
        _isLoading = true;
      });

      await _detectGender(File(pickedFile.path));
    }
  }

  Future<void> _detectGender(File image) async {
    final request = http.MultipartRequest('POST', Uri.parse('https://api.deepai.org/api/gender-recognition'));

    request.headers['api-key'] = '84105f6f-39cc-43d4-aa53-05ccaac34d76';
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    try {
      final response = await request.send();
      print("response:: ${response}");
      final responseData = await response.stream.bytesToString();

      final data = json.decode(responseData);

      String? gender;
      if (data['output'] != null &&
          data['output'] is List &&
          data['output'].isNotEmpty &&
          data['output'][0]['gender'] != null) {
        gender = data['output'][0]['gender'];
      }

      setState(() {
        debugPrint("gender::: $_gender");
        _gender = gender ?? 'Unknown';
        _isLoading = false;
      });

      debugPrint("gender::: $_gender");
    } catch (e) {
      setState(() {
        _gender = 'Error detecting gender';
        _isLoading = false;
      });

      debugPrint("gender error::: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  _pickedImage != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _pickedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                      : const Center(child: Text('Tap to pick image', style: TextStyle(color: Colors.grey))),
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const CircularProgressIndicator()
          else if (_gender != null)
            Text('Detected: $_gender', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          // debugPrint(_gender);
        ],
      ),
    );
  }
}

// view

class ImagePickerView extends StatelessWidget {
  final controller = Get.put(ImageController());

  ImagePickerView({super.key});

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    controller.pickFromGallery();
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    controller.pickFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final image = controller.pickedImage.value;
      final gender = controller.detectedGender.value;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _showPicker(context),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  image != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(image, fit: BoxFit.cover))
                      : const Center(child: Text('Tap to pick image')),
            ),
          ),
          const SizedBox(height: 16),
          if (gender.isNotEmpty) Text('Detected Gender: $gender', style: const TextStyle(fontSize: 18)),
        ],
      );
    });
  }
}
