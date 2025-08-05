import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_detection/custom_pick/detection_screen.dart';
import 'package:image_detection/image_picker_widget/image_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //
  // // Register the ImageService
  Get.put(ImageService());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: GenderDetectionScreen(),
    );
  }
}
