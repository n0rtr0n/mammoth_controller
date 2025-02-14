import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ParameterLabel(label: parameter.label),
            Row(
              children: [
                Text(
                  parameter.value.toInt().toString(),
                ),
                Expanded(
                  child: Slider(
                    value: parameter.value.toDouble(),
                    onChanged: onParameterUpdate,
                    min: parameter.min.toDouble(),
                    max: parameter.max.toDouble(),
                    divisions: parameter.max - parameter.min,
                  ),
                ),
              ], 
            )
          ],
        ),
      ),
    );
  }
}
