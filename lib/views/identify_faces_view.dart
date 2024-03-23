import 'dart:typed_data';

import 'package:flutter/material.dart';

class IdentifyFacesView extends StatefulWidget {
  final List<Uint8List> bytes;

  const IdentifyFacesView({super.key, required this.bytes});

  @override
  State<IdentifyFacesView> createState() => _IdentifyFacesViewState();
}

class _IdentifyFacesViewState extends State<IdentifyFacesView> {
  int _currentIndex = 0;

  List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.bytes.length,
      (index) => TextEditingController(),
    );
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
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: ElevatedButton(
                  onPressed: () {},
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
        ],
      ),
    );
  }
}
