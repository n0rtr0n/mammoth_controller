import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mammoth_controller/models/pattern.dart' as models;
import 'package:mammoth_controller/widgets/connection_status_bar.dart';

/// Represents a preset URL with a label for the dropdown
class PresetUrl {
  final String label;
  final String url;

  const PresetUrl(this.label, this.url);
}

class ConfigPage extends StatefulWidget {
  const ConfigPage({
    super.key,
    required this.currentPatterns,
    required this.onPatternsUpdated,
    required this.onThemeChanged,
  });

  final List<models.Pattern> currentPatterns;
  final Function(List<models.Pattern>) onPatternsUpdated;
  final Function(ThemeMode) onThemeChanged;

  // Constants
  static const baseUrlKey = 'base_url';
  static const themeModeKey = 'theme_mode';
  
  // URL Configuration
  static const mammothUrl = 'http://192.168.1.69:8008';
  static const localUrl = 'http://127.0.0.1:8008';
  static const defaultBaseUrl = mammothUrl;
  
  static const presetUrls = [
    PresetUrl('Mammoth', mammothUrl),
    PresetUrl('Local Development', localUrl),
  ];

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(baseUrlKey) ?? defaultBaseUrl;
  }

  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(themeModeKey);
    return ThemeMode.values[themeIndex ?? ThemeMode.system.index];
  }

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final _baseUrlController = TextEditingController();
  late SharedPreferences _prefs;
  String? _testResult;
  late ThemeMode _currentThemeMode;
  bool _isLoadingTheme = true;
  bool _isCustomUrl = false;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _loadThemeMode();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadBaseUrl();
  }

  void _loadBaseUrl() {
    final savedUrl = _prefs.getString(ConfigPage.baseUrlKey) ?? ConfigPage.defaultBaseUrl;
    setState(() {
      _baseUrlController.text = savedUrl;
      _isCustomUrl = !ConfigPage.presetUrls.any((preset) => preset.url == savedUrl);
    });
  }

  Future<void> _saveBaseUrl() async {
    setState(() {
      _testResult = 'Testing connection...';
    });

    final isConnected = await ConnectionStatusBar.checkConnection(_baseUrlController.text);

    if (isConnected) {
      await _prefs.setString(ConfigPage.baseUrlKey, _baseUrlController.text);
      if (!mounted) return;

      setState(() {
        _testResult = 'Success: Connected to API';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Base URL saved')),
      );
    } else {
      if (!mounted) return;
      setState(() {
        _testResult = 'Error: Could not connect to API';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to connect to API - URL not saved'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  Future<void> _loadThemeMode() async {
    final themeMode = await ConfigPage.getThemeMode();
    setState(() {
      _currentThemeMode = themeMode;
      _isLoadingTheme = false;
    });
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    await _prefs.setInt(ConfigPage.themeModeKey, mode.index);
    setState(() {
      _currentThemeMode = mode;
    });
    widget.onThemeChanged(mode);
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    super.dispose();
  }

  Widget _buildUrlSelector() {
    final isCurrentUrlInPresets = ConfigPage.presetUrls.any(
      (preset) => preset.url == _baseUrlController.text
    );
    final dropdownValue = isCurrentUrlInPresets ? _baseUrlController.text : null;

    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: dropdownValue,
          decoration: InputDecoration(
            labelText: 'Select API URL',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          items: [
            ...ConfigPage.presetUrls.map((preset) => DropdownMenuItem(
              value: preset.url,
              child: Text('${preset.label} (${preset.url})'),
            )),
            const DropdownMenuItem(
              value: null,
              child: Text('Custom URL'),
            ),
          ],
          onChanged: (String? value) {
            setState(() {
              _isCustomUrl = value == null;
              if (!_isCustomUrl) {
                _baseUrlController.text = value!;
              }
            });
          },
        ),
        if (_isCustomUrl) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _baseUrlController,
            decoration: InputDecoration(
              labelText: 'Custom URL',
              hintText: 'Enter the base URL for the API',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Config'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUrlSelector(),
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
                '• Hard-close and re-open the app if you are having issues',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              const Text(
                'Appearance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (!_isLoadingTheme) Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<ThemeMode>(
                    value: _currentThemeMode,
                    decoration: const InputDecoration(
                      labelText: 'Theme Mode',
                      border: InputBorder.none,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System Theme'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light Mode'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark Mode'),
                      ),
                    ],
                    onChanged: (ThemeMode? newMode) {
                      if (newMode != null) {
                        _saveThemeMode(newMode);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 