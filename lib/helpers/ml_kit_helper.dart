import 'dart:developer';
import 'package:image/image.dart' as img;
import 'dart:math' hide log;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:v_samples/helpers/image_helper.dart';
import 'package:v_samples/models/person.dart';

import '../db/database.dart';

class MLKitHelper {
  final double threshold = 0.9;

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

    for (Person p in persons) {
      currDist = _euclideanDistance(p.modelData, predictedData);
      log("actual distance: $currDist");
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        predictedResult = p;
      }
    }
    log('person: ${predictedResult?.name}, distance: $minDist');
    return predictedResult;
  }

  double _euclideanDistance(List<dynamic> e1, List<dynamic> e2) {
    if (e1.isEmpty || e2.isEmpty || e1.first is! List || e2.first is! List) {
      throw ArgumentError('Both e1 and e2 must be non-empty lists of lists.');
    }
    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      List<dynamic> innerList1 = e1[i];
      List<dynamic> innerList2 = e2[i];
      for (int j = 0; j < innerList1.length; j++) {
        double val1 = double.tryParse('${innerList1[j]}') ?? 0.0;
        double val2 = double.tryParse('${innerList2[j]}') ?? 0.0;
        sum += pow((val1 - val2), 2);
      }
    }
    return sqrt(sum);
  }
}
