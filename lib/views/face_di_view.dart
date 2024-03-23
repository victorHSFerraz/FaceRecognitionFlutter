import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:v_samples/helpers/ml_kit_helper.dart';
import 'package:v_samples/views/identify_faces_view.dart';
import 'package:v_samples/views/paint_faces_view.dart';

import '../helpers/image_helper.dart';

class FaceDIView extends StatefulWidget {
  const FaceDIView({super.key});

  @override
  State<FaceDIView> createState() => _FaceDIViewViewState();
}

class _FaceDIViewViewState extends State<FaceDIView> {
  Future<String?> _takePicture({required bool fromCamera}) async {
    if (fromCamera) {
      return ImageHelper().takePicture();
    } else {
      return ImageHelper().pickImage();
    }
  }

  Future<List<Uint8List?>> _getCropedFacesFromImage(String path) async {
    final faces = await MLKitHelper().detectFaces(path);

    if (faces.isEmpty) {
      return [];
    }

    final croppedFaces = await ImageHelper().cropFacesFromImage(faces, path);

    if (croppedFaces.isEmpty) {
      return [];
    }

    final byteList = ImageHelper().imagesToByteList(croppedFaces);

    return byteList;
  }

  Future<List<Face>> _getFacesFromImage(String path) async {
    final faces = await MLKitHelper().detectFaces(path);

    return faces;
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
              child: const Text('Take Picture & Paint Detected Faces'),
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
                            onPressed: () {},
                            child: const Text('Camera'),
                          ),
                          TextButton(
                            onPressed: () {},
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
        final image = await ImageHelper().fileToUiImage(path);
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
        _getCropedFacesFromImage(path).then((faces) {
          if (faces.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IdentifyFacesView(
                  bytes: faces.cast<Uint8List>(),
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
}
