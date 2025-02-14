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
          vertical: 14,
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
                Text(
                  '#${parameter.value.r.toRadixString(16).padLeft(2, '0')}'
                  '${parameter.value.g.toRadixString(16).padLeft(2, '0')}'
                  '${parameter.value.b.toRadixString(16).padLeft(2, '0')}'
                  .toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          parameter.value.r.toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: parameter.value.r.toDouble(),
                          onChanged: onRedParameterUpdate,
                          min: 0.toDouble(),
                          max: 255.toDouble(),
                          divisions: 255,
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: const Text(
                          "Red",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          parameter.value.g.toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: parameter.value.g.toDouble(),
                          onChanged: onGreenParameterUpdate,
                          min: 0.toDouble(),
                          max: 255.toDouble(),
                          divisions: 255,
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: const Text(
                          "Green",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          parameter.value.b.toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: parameter.value.b.toDouble(),
                          onChanged: onBlueParameterUpdate,
                          min: 0.toDouble(),
                          max: 255.toDouble(),
                          divisions: 255,
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: const Text(
                          "Blue",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
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
