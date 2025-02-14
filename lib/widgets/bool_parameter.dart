import 'package:flutter/material.dart';

import 'package:mammoth_controller/models/parameters.dart';
import 'package:mammoth_controller/widgets/parameter_label.dart';

class BoolParameterWidget extends StatelessWidget {
  final BoolParameter parameter;
  final void Function(bool value) onParameterUpdate;

  const BoolParameterWidget({
    super.key,
    required this.parameter,
    required this.onParameterUpdate,
  });

  @override
  Widget build(Object context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ParameterLabel(label: parameter.label),
            Switch(
              value: parameter.value,
              onChanged: onParameterUpdate,
            ),
          ],
        ),
      ),
    );
  }
}
