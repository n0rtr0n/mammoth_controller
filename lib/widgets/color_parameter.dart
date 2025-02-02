import 'package:flutter/material.dart';

import 'package:mammoth_controller/models/parameters.dart';
import 'package:mammoth_controller/widgets/parameter_label.dart';

class ColorParameterWidget extends StatelessWidget {
  final ColorParameter parameter;
  final void Function(double value) onRedParameterUpdate;
  final void Function(double value) onGreenParameterUpdate;
  final void Function(double value) onBlueParameterUpdate;

  const ColorParameterWidget({
    super.key,
    required this.parameter,
    required this.onRedParameterUpdate,
    required this.onGreenParameterUpdate,
    required this.onBlueParameterUpdate,
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
          children: [
            Column(
              children: [
                ParameterLabel(label: parameter.label),
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Card(
                    color: Color.fromRGBO(
                      parameter.value.r.toInt(),
                      parameter.value.g.toInt(),
                      parameter.value.b.toInt(),
                      1,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Red",
                  ),
                  Text(
                    parameter.value.r.toString(),
                  ),
                  Slider(
                    value: parameter.value.r.toDouble(),
                    onChanged: onRedParameterUpdate,
                    min: 0.toDouble(),
                    max: 255.toDouble(),
                    divisions: 255,
                  ),
                  const Text(
                    "Green",
                  ),
                  Text(
                    parameter.value.g.toString(),
                  ),
                  Slider(
                    value: parameter.value.g.toDouble(),
                    onChanged: onGreenParameterUpdate,
                    min: 0.toDouble(),
                    max: 255.toDouble(),
                    divisions: 255,
                  ),
                  const Text(
                    "Blue",
                  ),
                  Text(
                    parameter.value.b.toString(),
                  ),
                  Slider(
                    value: parameter.value.b.toDouble(),
                    onChanged: onBlueParameterUpdate,
                    min: 0.toDouble(),
                    max: 255.toDouble(),
                    divisions: 255,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
