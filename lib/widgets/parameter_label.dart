import 'package:flutter/material.dart';

class ParameterLabel extends StatelessWidget {
  final String label;
  const ParameterLabel({
    super.key,
    required this.label,
  });


  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.left,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
