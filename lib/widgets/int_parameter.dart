import 'package:flutter/material.dart';

import 'package:mammoth_controller/models/parameters.dart';
import 'package:mammoth_controller/widgets/parameter_label.dart';

class IntParameterWidget extends StatelessWidget {
  final IntParameter parameter;
  // we'll perform the conversion directly within this function
  final void Function(double value) onParameterUpdate;

  const IntParameterWidget({
    super.key,
    required this.parameter,
    required this.onParameterUpdate,
  });

  @override
  Widget build(Object context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ParameterLabel(label: parameter.label),
          ),
          SizedBox(
            width: 50,
            child: Text(
              parameter.value.toString(),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 3,
            child: Slider(
              value: parameter.value.toDouble(),
              onChanged: onParameterUpdate,
              min: parameter.min.toDouble(),
              max: parameter.max.toDouble(),
            ),
          ),
        ],
      ),
    );
  }
}
