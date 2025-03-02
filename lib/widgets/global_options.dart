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
    required this.onTransitionUpdated,
  });

  static const String transitionDurationKey = 'transition_duration';
  final VoidCallback onTransitionUpdated;

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
          ],
        ),
      ),
    );
  }
} 