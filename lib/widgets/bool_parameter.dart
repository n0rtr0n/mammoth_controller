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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ParameterLabel(label: parameter.label),
          ),
          Switch(
            value: parameter.value,
            onChanged: onParameterUpdate,
          ),
        ],
      ),
    );
  }
}
