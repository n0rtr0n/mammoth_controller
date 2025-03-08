import 'package:flutter/material.dart';
import 'package:mammoth_controller/models/options.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ColorCorrectionWidget extends StatefulWidget {
  final Option option;
  final String baseUrl;
  final Function(String message, bool isError) onStatusUpdate;

  const ColorCorrectionWidget({
    super.key,
    required this.option,
    required this.baseUrl,
    required this.onStatusUpdate,
  });

  @override
  State<ColorCorrectionWidget> createState() => _ColorCorrectionWidgetState();
}

class _ColorCorrectionWidgetState extends State<ColorCorrectionWidget> {
  late bool _enabled;
  late double _gamma;
  late Map<String, ColorCorrectionSection> _sections;
  bool _isExpanded = false;
  bool _isResetting = false;

  @override
  void initState() {
    super.initState();
    _initializeValues();
  }

  void _initializeValues() {
    final value = widget.option.value as Map<String, dynamic>;
    
    // Add debug logging
    print('Color correction value: $value');
    
    // Handle possible null or missing values
    _enabled = value['enabled'] as bool? ?? false;
    
    // Check if gamma exists and has the expected structure
    if (value['gamma'] != null && value['gamma'] is Map<String, dynamic>) {
      _gamma = (value['gamma']['value'] as num?)?.toDouble() ?? 1.0;
    } else {
      _gamma = 1.0; // Default value
    }
    
    _sections = {};
    
    // Check if sections exists and has the expected structure
    if (value['sections'] != null && value['sections'] is Map<String, dynamic>) {
      final sectionsData = value['sections'] as Map<String, dynamic>;
      sectionsData.forEach((key, sectionData) {
        try {
          _sections[key] = ColorCorrectionSection.fromJson(sectionData);
        } catch (e) {
          print('Error parsing section $key: $e');
        }
      });
    }
    
    // If no sections were loaded, create a default "all" section
    if (_sections.isEmpty) {
      _sections['all'] = ColorCorrectionSection(
        id: 'all',
        label: 'All',
        red: 100,
        green: 100,
        blue: 100,
      );
    }
  }

  Future<void> _updateEnabled(bool value) async {
    try {
      await Options.updateColorCorrectionEnabled(widget.baseUrl, value);
      setState(() {
        _enabled = value;
      });
      widget.onStatusUpdate('Color correction enabled state updated', false);
    } catch (e) {
      widget.onStatusUpdate('Failed to update color correction enabled state: $e', true);
    }
  }

  Future<void> _updateGamma(double value) async {
    try {
      await Options.updateColorCorrectionGamma(widget.baseUrl, value);
      setState(() {
        _gamma = value;
      });
      widget.onStatusUpdate('Gamma value updated', false);
    } catch (e) {
      widget.onStatusUpdate('Failed to update gamma value: $e', true);
    }
  }

  Future<void> _updateSection(String sectionId, String channel, double value) async {
    final section = _sections[sectionId]!;
    
    // Update the local value first
    switch (channel) {
      case 'red':
        section.red = value;
        break;
      case 'green':
        section.green = value;
        break;
      case 'blue':
        section.blue = value;
        break;
    }
    
    try {
      await Options.updateColorCorrectionSection(
        widget.baseUrl, 
        sectionId, 
        section.toJson()
      );
      widget.onStatusUpdate('Color correction updated for ${section.label}', false);
    } catch (e) {
      widget.onStatusUpdate('Failed to update color correction: $e', true);
      // Revert the local change if the API call fails
      _initializeValues();
    }
  }

  Future<void> _resetColorCorrection() async {
    setState(() {
      _isResetting = true;
    });
    
    try {
      // Call the reset color correction endpoint
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/options/resetColorCorrection'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      
      if (response.statusCode == 200) {
        widget.onStatusUpdate('Color correction reset to defaults', false);
        
        // Refresh the data
        final optionsResponse = await http.get(
          Uri.parse('${widget.baseUrl}/options'),
        );
        
        if (optionsResponse.statusCode == 200) {
          // Re-initialize with new values
          final options = Options.fromJson(
            jsonDecode(optionsResponse.body)
          );
          
          if (options.options.containsKey('colorCorrection')) {
            setState(() {
              _initializeValues();
            });
          }
        }
      } else {
        widget.onStatusUpdate('Failed to reset color correction: ${response.statusCode}', true);
      }
    } catch (e) {
      widget.onStatusUpdate('Error resetting color correction: $e', true);
    } finally {
      setState(() {
        _isResetting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with expand/collapse
          ListTile(
            title: Text(
              widget.option.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add Reset button
                _isResetting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Reset Color Correction',
                        onPressed: _resetColorCorrection,
                      ),
                Switch(
                  value: _enabled,
                  onChanged: _updateEnabled,
                ),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Expanded content
          if (_isExpanded) ...[
            // Gamma slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gamma',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _gamma,
                          min: 0.2,
                          max: 3.0,
                          divisions: 28,
                          label: _gamma.toStringAsFixed(1),
                          onChanged: (value) {
                            setState(() {
                              _gamma = value;
                            });
                          },
                          onChangeEnd: _updateGamma,
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: Text(
                          _gamma.toStringAsFixed(1),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Divider
            const Divider(),
            
            // Sections
            ..._sections.entries.map((entry) {
              final section = entry.value;
              return _buildSectionWidget(section);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionWidget(ColorCorrectionSection section) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.label,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          
          // Red slider
          _buildColorSlider(
            'Red', 
            section.red, 
            Colors.red, 
            (value) => _updateSection(section.id, 'red', value),
            section.id
          ),
          
          // Green slider
          _buildColorSlider(
            'Green', 
            section.green, 
            Colors.green, 
            (value) => _updateSection(section.id, 'green', value),
            section.id
          ),
          
          // Blue slider
          _buildColorSlider(
            'Blue', 
            section.blue, 
            Colors.blue, 
            (value) => _updateSection(section.id, 'blue', value),
            section.id
          ),
          
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildColorSlider(
    String label, 
    double value, 
    Color color, 
    Function(double) onChangeEnd,
    String sectionId
  ) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(label),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color.withOpacity(0.8),
              thumbColor: color,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 200,
              divisions: 200,
              label: value.toStringAsFixed(0),
              onChanged: (newValue) {
                setState(() {
                  switch (label) {
                    case 'Red':
                      _sections[sectionId]!.red = newValue;
                      break;
                    case 'Green':
                      _sections[sectionId]!.green = newValue;
                      break;
                    case 'Blue':
                      _sections[sectionId]!.blue = newValue;
                      break;
                  }
                });
              },
              onChangeEnd: onChangeEnd,
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            value.toStringAsFixed(0),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
} 