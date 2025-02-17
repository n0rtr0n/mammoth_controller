import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:math';

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

  Color _getRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),  // Red
      random.nextInt(256),  // Green
      random.nextInt(256),  // Blue
      1,                    // Alpha
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _ColorPickerDialog(
          initialColor: Color.fromRGBO(
            parameter.value.r.toInt(),
            parameter.value.g.toInt(),
            parameter.value.b.toInt(),
            1,
          ),
          onRedParameterUpdate: onRedParameterUpdate,
          onGreenParameterUpdate: onGreenParameterUpdate,
          onBlueParameterUpdate: onBlueParameterUpdate,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                GestureDetector(
                  onTap: () => _showColorPicker(context),
                  child: SizedBox(
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

class _ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final void Function(double) onRedParameterUpdate;
  final void Function(double) onGreenParameterUpdate;
  final void Function(double) onBlueParameterUpdate;

  const _ColorPickerDialog({
    required this.initialColor,
    required this.onRedParameterUpdate,
    required this.onGreenParameterUpdate,
    required this.onBlueParameterUpdate,
  });

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color currentColor;

  @override
  void initState() {
    super.initState();
    currentColor = widget.initialColor;
  }

  Color _getRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }

  void _updateColor(Color color) {
    setState(() {
      currentColor = color;
    });
    widget.onRedParameterUpdate(color.red.toDouble());
    widget.onGreenParameterUpdate(color.green.toDouble());
    widget.onBlueParameterUpdate(color.blue.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a color'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorPicker(
              pickerColor: currentColor,
              onColorChanged: _updateColor,
              pickerAreaHeightPercent: 0.8,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                _updateColor(_getRandomColor());
              },
              icon: const Icon(Icons.shuffle),
              label: const Text('Random Color'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Done'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
