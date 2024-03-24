import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:ui' as ui;

import '../shared/face_painter.dart';

class PaintFacesView extends StatefulWidget {
  final List<Face> faces;
  final ui.Image image;
  const PaintFacesView({super.key, required this.faces, required this.image});

  @override
  State<PaintFacesView> createState() => _PaintFacesViewState();
}

class _PaintFacesViewState extends State<PaintFacesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detected Faces')),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: FittedBox(
            child: SizedBox(
              width: widget.image.width.toDouble(),
              height: widget.image.height.toDouble(),
              child: CustomPaint(
                painter: FacePainter(
                  facesList: widget.faces,
                  imageFile: widget.image,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
