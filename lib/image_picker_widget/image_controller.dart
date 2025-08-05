import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'image_service.dart';

class ImageController extends GetxController {
  static ImageController get to => Get.isRegistered<ImageController>() ? Get.find() : Get.put(ImageController());

  final ImageService imageService = Get.find<ImageService>();

  Rx<File?> pickedImage = Rx<File?>(null);
  RxString detectedGender = ''.obs;

  Future<void> pickFromCamera() async {
    pickedImage.value = await imageService.pickImage(source: ImageSource.camera);
    if (pickedImage.value != null) {
      detectGenderFromImage(pickedImage.value!);
    }
  }

  Future<void> pickFromGallery() async {
    pickedImage.value = await imageService.pickImage(source: ImageSource.gallery);
    if (pickedImage.value != null) {
      detectGenderFromImage(pickedImage.value!);
    }
  }

  Future<void> detectGenderFromImage(File imageFile) async {
    //
  }
}
