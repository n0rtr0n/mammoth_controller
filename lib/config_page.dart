import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mammoth_controller/models/pattern.dart' as models;

class ConfigPage extends StatefulWidget {
  const ConfigPage({
    super.key,
    required this.currentPatterns,
    required this.onPatternsUpdated,
  });

  final List<models.Pattern> currentPatterns;
  final Function(List<models.Pattern>) onPatternsUpdated;

  static const defaultBaseUrl = 'http://127.0.0.1:8008';
  static const baseUrlKey = 'base_url';

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(baseUrlKey) ?? defaultBaseUrl;
  }

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final _baseUrlController = TextEditingController();
  late SharedPreferences _prefs;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }


  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadBaseUrl();
  }

  void _loadBaseUrl() {
    setState(() {
      _baseUrlController.text = _prefs.getString(ConfigPage.baseUrlKey) ?? ConfigPage.defaultBaseUrl;
    });
  }

  Future<void> _saveBaseUrl() async {
    await _prefs.setString(ConfigPage.baseUrlKey, _baseUrlController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Base URL saved')),
    );
  }

  void _resetToDefault() {
    setState(() {
      _baseUrlController.text = ConfigPage.defaultBaseUrl;
    });
    _saveBaseUrl();
  }

  Future<void> _testConnection() async {
    setState(() {
      _testResult = 'Testing...';
    });

    try {
      final response = await http.get(
        Uri.parse('${_baseUrlController.text}/health'),
      ).timeout(const Duration(seconds: 5));

      setState(() {
        _testResult = response.statusCode == 200
            ? 'Success: API is up and running!'
            : 'Error: API returned status ${response.statusCode}';
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error: Could not connect to API';
      });
    }
  }

  Future<void> _fetchPatterns() async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrlController.text}/patterns'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final Map<String, dynamic> patternsData = data['patterns'];
        final List<models.Pattern> fetchedPatterns = [];
        patternsData.forEach((key, pattern) {
          fetchedPatterns.add(models.Pattern.fromJson(key, pattern));
        });

        widget.onPatternsUpdated(fetchedPatterns);
        if (!mounted) return;
        Navigator.pop(context, fetchedPatterns);
      } else {
        throw Exception('Failed to fetch patterns');
      }
    } catch (e) {
      setState(() {
        _testResult = 'Error: Failed to fetch patterns: $e';
      });
    }
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Config'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _baseUrlController,
              decoration: InputDecoration(
                labelText: 'Base URL',
                hintText: 'Enter the base URL for the API',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _saveBaseUrl,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
                ElevatedButton.icon(
                  onPressed: _resetToDefault,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset'),
                ),
                ElevatedButton.icon(
                  onPressed: _testConnection,
                  icon: const Icon(Icons.wifi),
                  label: const Text('Test'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchPatterns,
              icon: const Icon(Icons.refresh),
              label: const Text('Fetch Patterns'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            if (_testResult != null) ...[
              const SizedBox(height: 8),
              Text(
                _testResult!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _testResult!.startsWith('Success')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Troubleshooting',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              '• Make sure you are connected to the Mammoth WiFi\n'
              '• The default URL should work when connected',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
} 