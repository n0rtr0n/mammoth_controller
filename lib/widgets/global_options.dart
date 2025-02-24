import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mammoth_controller/config_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mammoth_controller/models/pattern.dart';
import 'package:mammoth_controller/models/parameters.dart';
import 'package:mammoth_controller/widgets/bool_parameter.dart';
import 'package:mammoth_controller/widgets/color_parameter.dart';
import 'package:mammoth_controller/widgets/float_parameter.dart';
import 'package:mammoth_controller/widgets/int_parameter.dart';

class GlobalOptions extends StatefulWidget {
  const GlobalOptions({
    super.key,
    required this.colorMasks,
    required this.onColorMaskUpdated,
  });

  static const String transitionDurationKey = 'transition_duration';
  final Map<String, Pattern> colorMasks;
  final void Function(String) onColorMaskUpdated;

  @override
  State<GlobalOptions> createState() => _GlobalOptionsState();
}

class _GlobalOptionsState extends State<GlobalOptions> {
  double _transitionDuration = 0;
  String? _baseUrl;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadBaseUrl();
    _loadTransitionSettings();
  }

  Future<void> _loadTransitionSettings() async {
    setState(() {
      _transitionDuration = _prefs.getDouble(GlobalOptions.transitionDurationKey) ?? 0;
    });
  }

  Future<void> _saveTransitionSettings() async {
    await _prefs.setDouble(GlobalOptions.transitionDurationKey, _transitionDuration);
  }

  Future<void> _loadBaseUrl() async {
    final url = await ConfigPage.getBaseUrl();
    setState(() {
      _baseUrl = url;
    });
  }

  Future<void> _updateTransition() async {
    if (_baseUrl == null) return;

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/transition'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'duration': _transitionDuration.toInt(),
          'enabled': true,  // Always set to true
        }),
      );

      if (response.statusCode == 200) {
        await _saveTransitionSettings();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update transition settings'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating transition settings'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateColorMask(String id, Pattern mask) async {
    if (_baseUrl == null) return;

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/colorMasks/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(mask.toJson()),
      );

      if (response.statusCode == 200) {
        widget.onColorMaskUpdated(mask.label);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update color mask'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating color mask'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildParameterWidgets(Pattern mask) {
    final parameters = <AdjustableParameter>[];
    mask.parameters?.forEach((key, item) {
      parameters.add(item);
    });

    return ListView.builder(
      itemCount: parameters.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final param = parameters[index];
        final Widget widget;
        
        if (param is FloatParameter) {
          void onParameterUpdate(double value) {
            setState(() {
              param.setValue(value);
            });
          }

          widget = FloatParameterWidget(
            parameter: param,
            onParameterUpdate: onParameterUpdate,
          );
        } else if (param is BoolParameter) {
          void onParameterUpdate(bool value) {
            setState(() {
              param.setValue(value);
            });
          }

          widget = BoolParameterWidget(
            parameter: param,
            onParameterUpdate: onParameterUpdate,
          );
        } else if (param is IntParameter) {
          void onParameterUpdate(double value) {
            setState(() {
              param.setValue(value.toInt());
            });
          }

          widget = IntParameterWidget(
            parameter: param,
            onParameterUpdate: onParameterUpdate,
          );
        } else if (param is ColorParameter) {
          void onRedParameterUpdate(double value) {
            setState(() {
              param.setRed(value.toInt());
            });
          }

          void onGreenParameterUpdate(double value) {
            setState(() {
              param.setGreen(value.toInt());
            });
          }

          void onBlueParameterUpdate(double value) {
            setState(() {
              param.setBlue(value.toInt());
            });
          }

          widget = ColorParameterWidget(
            parameter: param,
            onRedParameterUpdate: onRedParameterUpdate,
            onGreenParameterUpdate: onGreenParameterUpdate,
            onBlueParameterUpdate: onBlueParameterUpdate,
          );
        } else {
          widget = const Card(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "non-implemented param.value",
                  ),
                ],
              ),
            ),
          );
        }

        return widget;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Global Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Transition Time',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _transitionDuration,
                    min: 0,
                    max: 20000,
                    divisions: 40,
                    label: '${_transitionDuration.toInt()}ms',
                    onChanged: (value) {
                      setState(() {
                        _transitionDuration = value;
                      });
                    },
                    onChangeEnd: (value) {
                      _updateTransition();
                    },
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    '${_transitionDuration.toInt()}ms',
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Color Masks',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...widget.colorMasks.entries.map((entry) {
              final mask = entry.value;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mask.label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      if (mask.parameters?.isNotEmpty ?? false)
                        _buildParameterWidgets(mask),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _updateColorMask(entry.key, mask),
                        child: const Text('Update Mask'),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
} 