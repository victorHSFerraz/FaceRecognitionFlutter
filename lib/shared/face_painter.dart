import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:ui' as ui;

import 'package:v_samples/models/person.dart';

class FacePainter extends CustomPainter {
  List<Face> facesList;
  ui.Image? imageFile;
  List<Person> recognizedPersons;
  FacePainter({required this.facesList, required this.imageFile, required this.recognizedPersons});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile!, Offset.zero, Paint());
    }

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.red;

    for (int i = 0; i < facesList.length; i++) {
      final Rect boundingBox = facesList[i].boundingBox;
      canvas.drawRect(boundingBox, paint);

      if (recognizedPersons.isEmpty || recognizedPersons.length <= i) {
        continue;
      }

      TextSpan span = TextSpan(
        style: const TextStyle(color: Colors.red, fontSize: 20.0),
        text: recognizedPersons[i].name,
      );

      TextPainter tp = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(boundingBox.left, boundingBox.top - tp.height - 5));
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return true;
  }
}
