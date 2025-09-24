import 'package:flutter/material.dart';

class InputPasswordSection extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const InputPasswordSection({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  _InputPasswordSectionState createState() => _InputPasswordSectionState();
}

class _InputPasswordSectionState extends State<InputPasswordSection> {
  bool _obscureText = true;

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one digit';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscureText,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: widget.hintText,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
        ),
        validator: _validatePassword,
      ),
    );
  }
}