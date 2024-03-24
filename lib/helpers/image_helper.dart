import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart';
import 'dart:ui' as ui;

class ImageHelper {
  late final ImagePicker _picker;

  ImageHelper() {
    _picker = ImagePicker();
  }

  Future<String?> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return pickedFile?.path;
  }

  Future<String?> takePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    return pickedFile?.path;
  }

  Future<Image?> fileToImage(String path) async {
    final bytes = await File(path).readAsBytes();
    return decodeImage(Uint8List.fromList(bytes));
  }

  Future<ui.Image?> fileToUiImage(String path) async {
    ui.Image? image;
    final bytes = await File(path).readAsBytes();
    final codec = await ui.instantiateImageCodec(Uint8List.fromList(bytes));
    final frame = await codec.getNextFrame();
    image = frame.image;
    return image;
  }

  Future<List<Image>> cropFacesFromImage(List<Face> faces, String path) async {
    final image = await fileToImage(path);

    if (image == null) {
      return [];
    }

    List<Image> croppedFaces = [];

    for (final face in faces) {
      final croppedFace = await cropFaceFromImage(face, path);
      if (croppedFace != null) {
        croppedFaces.add(croppedFace);
      }
    }

    return croppedFaces;
  }

  Future<Image?> cropFaceFromImage(Face face, String path) async {
    final image = await fileToImage(path);

    if (image == null) {
      return null;
    }

    final Rect boundingBox = face.boundingBox;

    num left = boundingBox.left < 0 ? 0 : boundingBox.left;
    num top = boundingBox.top < 0 ? 0 : boundingBox.top;
    num right = boundingBox.right > image.width ? image.width - 1 : boundingBox.right;
    num bottom = boundingBox.bottom > image.height ? image.height - 1 : boundingBox.bottom;
    num width = right - left;
    num height = bottom - top;

    final bytes = File(path).readAsBytesSync();
    Image? faceImg = decodeImage(bytes);

    if (faceImg == null) {
      return null;
    }

    Image? croppedFace = copyCrop(faceImg, x: left.toInt(), y: top.toInt(), width: width.toInt(), height: height.toInt());

    return croppedFace;
  }

  Uint8List imageToByteList(Image image) {
    return Uint8List.fromList(encodeBmp(image));
  }

  List<Uint8List> imagesToByteList(List<Image> images) {
    return images.map((image) => imageToByteList(image)).toList();
  }

  List<double> imageToByteListFloat32(Image inputImage) {
    final resizedImage = copyResize(inputImage, width: 112, height: 112);
    return Float32List.fromList(resizedImage.getBytes().map((b) => (b - 127.5) / 127.5).toList());
  }

  List<Image?> byteListToImage(List<Uint8List> bytes) {
    return bytes.map((byte) => decodeImage(byte)).toList();
  }
}
