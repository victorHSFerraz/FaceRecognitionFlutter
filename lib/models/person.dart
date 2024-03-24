import 'dart:convert';

class Person {
  final String name;
  final List modelData;

  Person({required this.name, required this.modelData});

  static Person fromMap(Map<String, dynamic> user) {
    return Person(
      name: user['name'],
      modelData: jsonDecode(user['model_data']),
    );
  }

  toMap() {
    return {
      'name': name,
      'model_data': jsonEncode(modelData),
    };
  }
}
