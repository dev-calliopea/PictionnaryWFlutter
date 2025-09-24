import 'package:flutter/material.dart';

class InputSection extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const InputSection({super.key, required this.controller, required this.hintText});

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }
    String pattern = r'\w+@\w+\.\w+';
    if (!RegExp(pattern).hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: hintText,
        ),
        validator: _validateEmail,
      ),
    );
  }
}