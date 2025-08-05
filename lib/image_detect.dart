import 'package:flutter/material.dart';
import 'package:image_detection/image_picker_widget/image_picker_box.dart';

class ImageDetect extends StatelessWidget {
  const ImageDetect({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Image Box")), body: Center(child: ImagePickerBox()));
  }
}
