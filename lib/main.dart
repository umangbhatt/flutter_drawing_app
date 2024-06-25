import 'package:flutter/material.dart';
import 'package:flutter_drawing_app_sample/src/views/canvas_view.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CanvasView(),
    );
  }
}
