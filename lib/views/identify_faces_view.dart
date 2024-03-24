import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:v_samples/db/database.dart';
import 'package:v_samples/helpers/ml_kit_helper.dart';

import '../models/person.dart';

class IdentifyFacesView extends StatefulWidget {
  final List<Uint8List> bytes;
  final String imagePath;
  final List<Face> faces;

  const IdentifyFacesView({super.key, required this.bytes, required this.imagePath, required this.faces});

  @override
  State<IdentifyFacesView> createState() => _IdentifyFacesViewState();
}

class _IdentifyFacesViewState extends State<IdentifyFacesView> {
  final MLKitHelper _mlKitHelper = MLKitHelper();
  int _currentIndex = 0;
  bool _isProcessing = false;

  List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.bytes.length,
      (index) => TextEditingController(),
    );
  }

  void _saveIdentifiedFaces() async {
    setState(() {
      _isProcessing = true;
    });
    try {
      DatabaseHelper databaseHelper = DatabaseHelper.instance;

      for (int i = 0; i < widget.bytes.length; i++) {
        if (_controllers[i].text.isEmpty) continue;

        final modelData = await _mlKitHelper.processFaceImageForRecognition(widget.imagePath, widget.faces[i]);

        if (modelData != null) {
          final person = Person(
            name: _controllers[i].text,
            modelData: modelData,
          );

          databaseHelper.insert(person);
          log('Inserted: ${person.name}');
        }
      }
    } catch (e) {
      log('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Identification')),
      body: Stack(
        children: [
          PageView.builder(
            itemCount: widget.bytes.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              if (widget.bytes.isEmpty) {
                return const Center(
                  child: Text('No Data'),
                );
              }
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Image.memory(
                        widget.bytes[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Image ${index + 1}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _controllers[index],
                        decoration: const InputDecoration(
                          labelText: 'Enter the name of the person',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (widget.bytes.length > 1 && _currentIndex < widget.bytes.length - 1)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.bytes.length,
                  (index) => Container(
                    margin: const EdgeInsets.all(4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _currentIndex == index ? Colors.blue : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          if (_currentIndex == widget.bytes.length - 1)
            Visibility(
              visible: !_isProcessing,
              replacement: const Center(
                child: CircularProgressIndicator(),
              ),
              child: Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: ElevatedButton(
                    onPressed: () {
                      _saveIdentifiedFaces();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    child: const Text(
                      'Finish',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
