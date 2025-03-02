import 'package:flutter/material.dart';

import 'package:mammoth_controller/models/parameters.dart';
import 'package:mammoth_controller/widgets/parameter_label.dart';

class FloatParameterWidget extends StatelessWidget {
  final FloatParameter parameter;
  final void Function(double value) onParameterUpdate;

  const FloatParameterWidget({
    super.key,
    required this.parameter,
    required this.onParameterUpdate,
  });

  @override
  Widget build(Object context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ParameterLabel(label: parameter.label),
          ),
          SizedBox(
            width: 50,
            child: Text(
              parameter.value.toStringAsFixed(2),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 3,
            child: Slider(
              value: parameter.value,
              onChanged: onParameterUpdate,
              min: parameter.min,
              max: parameter.max,
            ),
          ),
        ],
      ),
    );
  }
}
