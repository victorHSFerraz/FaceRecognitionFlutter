import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:v_samples/helpers/ml_kit_helper.dart';
import 'package:v_samples/models/person.dart';
import 'package:v_samples/views/identify_faces_view.dart';
import 'package:v_samples/views/paint_faces_view.dart';

import '../helpers/image_helper.dart';

class FaceDIView extends StatefulWidget {
  const FaceDIView({super.key});

  @override
  State<FaceDIView> createState() => _FaceDIViewViewState();
}

class _FaceDIViewViewState extends State<FaceDIView> {
  final ImageHelper _imageHelper = ImageHelper();
  final MLKitHelper _mlKitHelper = MLKitHelper();

  Future<String?> _takePicture({required bool fromCamera}) async {
    if (fromCamera) {
      return _imageHelper.takePicture();
    } else {
      return _imageHelper.pickImage();
    }
  }

  Future<FacesInfo?> _getCropedFacesFromImage(String path) async {
    final faces = await _mlKitHelper.detectFaces(path);

    if (faces.isEmpty) {
      return null;
    }

    final croppedFaces = await _imageHelper.cropFacesFromImage(faces, path);

    if (croppedFaces.isEmpty) {
      return null;
    }

    final byteList = _imageHelper.imagesToByteList(croppedFaces);

    return FacesInfo(bytes: byteList, faces: faces);
  }

  Future<List<Face>> _getFacesFromImage(String path) async {
    final faces = await _mlKitHelper.detectFaces(path);

    return faces;
  }

  Future<List<Person>> recognizeFaces(String imagePath, List<Face> faces) async {
    List<Person> recognizedPersons = [];
    for (final face in faces) {
      final value = await _mlKitHelper.processFaceImageForRecognition(imagePath, face);
      if (value != null) {
        final person = await _mlKitHelper.identifyFace(value);
        if (person != null) {
          recognizedPersons.add(person);
        }
      }
    }
    return recognizedPersons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detect, Identify & Recognize'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return SizedBox(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => _paintFaces(true, context),
                            child: const Text('Camera'),
                          ),
                          TextButton(
                            onPressed: () => _paintFaces(false, context),
                            child: const Text('Gallery'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: const Text('Take Picture & Frame Detected Faces'),
            ),
            TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return SizedBox(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => _identifyFaces(true, context),
                            child: const Text('Camera'),
                          ),
                          TextButton(
                            onPressed: () => _identifyFaces(false, context),
                            child: const Text('Gallery'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: const Text('Take Picture & Identify Faces'),
            ),
            TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return SizedBox(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => _recognizeFaces(true, context),
                            child: const Text('Camera'),
                          ),
                          TextButton(
                            onPressed: () => _recognizeFaces(false, context),
                            child: const Text('Gallery'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: const Text('Take Picture & Recognize Faces'),
            ),
          ],
        ),
      ),
    );
  }

  void _paintFaces(bool fromCamera, BuildContext context) {
    _takePicture(fromCamera: fromCamera).then((path) async {
      if (path != null) {
        final image = await _imageHelper.fileToUiImage(path);
        _getFacesFromImage(path).then((faces) {
          if (faces.isNotEmpty && image != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaintFacesView(
                  faces: faces,
                  image: image,
                ),
              ),
            );
          } else {
            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No faces detected'),
              ),
            );
          }
        });
      }
    });
  }

  void _identifyFaces(bool fromCamera, BuildContext context) {
    _takePicture(fromCamera: fromCamera).then((path) {
      if (path != null) {
        _getCropedFacesFromImage(path).then((info) {
          if (info != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IdentifyFacesView(
                  bytes: info.bytes.cast<Uint8List>(),
                  faces: info.faces,
                  imagePath: path,
                ),
              ),
            );
          } else {
            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No faces detected'),
              ),
            );
          }
        });
      }
    });
  }

  void _recognizeFaces(bool fromCamera, BuildContext context) async {
    final path = await _takePicture(fromCamera: fromCamera);
    if (path != null) {
      final image = await _imageHelper.fileToUiImage(path);
      final faces = await _getFacesFromImage(path);
      if (faces.isNotEmpty && image != null) {
        await recognizeFaces(path, faces).then(
          (persons) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaintFacesView(
                faces: faces,
                image: image,
                recognizedPersons: persons,
              ),
            ),
          ),
        );
      }
    }
  }
}

class FacesInfo {
  final List<Face> faces;
  final List<Uint8List> bytes;

  FacesInfo({required this.bytes, required this.faces});
}
