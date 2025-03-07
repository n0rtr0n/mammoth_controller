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
    final currentColor = Color.fromRGBO(
      parameter.value.r.toInt(),
      parameter.value.g.toInt(),
      parameter.value.b.toInt(),
      1,
    );
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ParameterLabel(label: parameter.label),
          ),
          GestureDetector(
            onTap: () => _showColorPicker(context),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: currentColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(width: 8),
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
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () => _showColorPicker(context),
          ),
          IconButton(
            icon: const Icon(Icons.shuffle, size: 20),
            tooltip: 'Random Color',
            onPressed: () {
              final random = Random();
              final randomColor = Color.fromRGBO(
                random.nextInt(256),
                random.nextInt(256),
                random.nextInt(256),
                1,
              );
              onRedParameterUpdate(randomColor.red.toDouble());
              onGreenParameterUpdate(randomColor.green.toDouble());
              onBlueParameterUpdate(randomColor.blue.toDouble());
            },
          ),
        ],
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
