import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImageService extends GetxService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage({required ImageSource source}) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 85);
    return pickedFile != null ? File(pickedFile.path) : null;
  }
}
