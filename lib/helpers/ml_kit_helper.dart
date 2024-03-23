import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class MLKitHelper {
  late final FaceDetector _faceDetector;

  MLKitHelper() {
    final options = FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate);
    _faceDetector = FaceDetector(options: options);
  }

  Future<List<Face>> detectFaces(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final faces = await _faceDetector.processImage(inputImage);
    return faces;
  }
}
