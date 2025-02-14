import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

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
            const SizedBox(height: 24),
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
            if (_testResult != null) ...[
              const SizedBox(height: 16),
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
          ],
        ),
      ),
    );
  }
} 