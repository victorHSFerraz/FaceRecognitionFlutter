import 'dart:developer';
import 'package:image/image.dart' as img;
import 'dart:math' hide log;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:v_samples/helpers/image_helper.dart';
import 'package:v_samples/models/person.dart';

import '../db/database.dart';

class MLKitHelper {
  final double threshold = 0.5;

  late final FaceDetector _faceDetector;
  late final Interpreter _interpreter;

  static const String modelName = 'assets/mobilefacenet.tflite';

  MLKitHelper() {
    _initialize();
  }

  Future<void> _initialize() async {
    final options = FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate);
    _faceDetector = FaceDetector(options: options);

    try {
      _interpreter = await Interpreter.fromAsset(modelName);
    } catch (e) {
      log("Error loading model: $e");
    }
  }

  Future<List<Face>> detectFaces(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final faces = await _faceDetector.processImage(inputImage);
    return faces;
  }

  Future<List<dynamic>?> processFaceImageForRecognition(String imagePath, Face face) async {
    final img.Image? preprocessedImage = await _preProcessImage(imagePath, face);
    if (preprocessedImage == null) {
      log("Image preprocessing failed");
      return null;
    }

    _interpreter.allocateTensors();

    final input = ImageHelper().imageToByteListFloat32(preprocessedImage).reshape([1, 112, 112, 3]);
    final output = List.filled(1 * 192, 0.0).reshape([1, 192]);

    _interpreter.run(input, output);

    return output;
  }

  Future<img.Image?> _preProcessImage(String imagePath, Face face) async {
    final croppedImage = await ImageHelper().cropFaceFromImage(face, imagePath);
    if (croppedImage == null) {
      return null;
    }

    final img.Image resizedImage = img.copyResize(croppedImage, width: 112, height: 112);

    return resizedImage;
  }

  Future<Person?> identifyFace(List predictedData) async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;

    List<Person> persons = await dbHelper.queryAllPersons();
    double minDist = 999;
    double currDist = 0.0;
    Person? predictedResult = Person(name: "Unknown", modelData: []);

    log('persons.length=> ${persons.length}');

    for (Person p in persons) {
      currDist = _euclideanDistance(p.modelData, predictedData);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        predictedResult = p;
      }
    }
    return predictedResult;
  }

  double _euclideanDistance(List e1, List e2) {
    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }
    return sqrt(sum);
  }
}
