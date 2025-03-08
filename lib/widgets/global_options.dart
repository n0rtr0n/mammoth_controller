import 'package:flutter/material.dart';
import 'package:mammoth_controller/config_page.dart';
import 'package:mammoth_controller/models/options.dart';
import 'package:mammoth_controller/widgets/color_correction_widget.dart';
import 'package:http/http.dart' as http;

class GlobalOptions extends StatefulWidget {
  const GlobalOptions({
    super.key,
    required this.onTransitionUpdated,
  });

  final VoidCallback onTransitionUpdated;

  @override
  State<GlobalOptions> createState() => _GlobalOptionsState();
}

class _GlobalOptionsState extends State<GlobalOptions> {
  String? _baseUrl;
  bool _isLoading = true;
  bool _isResetting = false;
  Options? _options;
  String? _errorMessage;
  String? _statusMessage;
  bool _isStatusError = false;
  bool patternTransitionEnabled = false;
  bool colorMaskTransitionEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBaseUrl();
  }

  Future<void> _loadBaseUrl() async {
    final url = await ConfigPage.getBaseUrl();
    setState(() {
      _baseUrl = url;
    });
    _fetchOptions();
  }

  Future<void> _fetchOptions() async {
    if (_baseUrl == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final options = await Options.fetchOptions();
      setState(() {
        _options = options;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load options: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _resetOptions() async {
    if (_baseUrl == null) return;

    setState(() {
      _isResetting = true;
      _statusMessage = 'Resetting options...';
      _isStatusError = false;
    });

    try {
      // Call the reset endpoint
      final response = await http.post(
        Uri.parse('$_baseUrl/options/reset'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      
      if (response.statusCode == 200) {
        // Fetch the updated options
        await _fetchOptions();
        setState(() {
          _isResetting = false;
          _statusMessage = 'Options reset to defaults. Color correction settings are preserved.';
          _isStatusError = false;
        });
        widget.onTransitionUpdated();
      } else {
        setState(() {
          _isResetting = false;
          _statusMessage = 'Failed to reset options: ${response.statusCode}';
          _isStatusError = true;
        });
      }
    } catch (e) {
      setState(() {
        _isResetting = false;
        _statusMessage = 'Error resetting options: $e';
        _isStatusError = true;
      });
    }
  }

  Future<void> _updateOption(String optionId, dynamic value) async {
    if (_baseUrl == null || _options == null) return;

    try {
      await Options.updateOption(_baseUrl!, optionId, value);
      
      // Update local state
      setState(() {
        _options!.options[optionId]?.value = value;
        _statusMessage = 'Option updated successfully. Color correction settings are preserved.';
        _isStatusError = false;
      });
      
      widget.onTransitionUpdated();
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to update option: $e';
        _isStatusError = true;
      });
    }
  }

  void _onStatusUpdate(String message, bool isError) {
    setState(() {
      _statusMessage = message;
      _isStatusError = isError;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Error',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchOptions,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final options = _options?.options ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Global Options',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton.icon(
                  onPressed: _isResetting ? null : _resetOptions,
                  icon: _isResetting 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.restore),
                  label: const Text('Reset to Defaults'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.errorContainer,
                    foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Status message
            if (_statusMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isStatusError ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isStatusError ? Icons.error : Icons.check_circle,
                      color: _isStatusError ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: TextStyle(
                          color: _isStatusError ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Build all options dynamically
            ...options.entries.map((entry) {
              final option = entry.value;
              
              // Special handling for colorCorrection
              if (option.type == 'colorCorrection') {
                // Add debug logging
                print('Found colorCorrection option: ${option.id}');
                print('Value: ${option.value}');
                
                // Ensure the value is a Map
                if (option.value is Map<String, dynamic>) {
                  return ColorCorrectionWidget(
                    option: option,
                    baseUrl: _baseUrl!,
                    onStatusUpdate: _onStatusUpdate,
                  );
                } else {
                  // If value is not a Map, show an error
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Color Correction',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error: Invalid color correction data format',
                            style: TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _fetchOptions,
                            child: const Text('Refresh Options'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }
              
              // Handle other option types
              switch (option.type) {
                case 'boolean':
                  return _buildBooleanOption(option);
                case 'duration':
                  return _buildDurationOption(option);
                case 'float':
                  return _buildFloatOption(option);
                case 'int':
                  return _buildIntOption(option);
                default:
                  return const SizedBox.shrink(); // Skip unknown option types
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatOption(Option option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            option.label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: option.value.toDouble(),
                  min: option.min?.toDouble() ?? 0,
                  max: option.max?.toDouble() ?? 100,
                  label: option.value.toString(),
                  onChanged: (value) {
                    setState(() {
                      option.value = value;
                    });
                  },
                  onChangeEnd: (value) {
                    _updateOption(option.id, value);
                  },
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  option.value.toStringAsFixed(1),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntOption(Option option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            option.label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: option.value.toDouble(),
                  min: option.min?.toDouble() ?? 0,
                  max: option.max?.toDouble() ?? 100,
                  label: option.value.toString(),
                  onChanged: (value) {
                    setState(() {
                      option.value = value.round();
                    });
                  },
                  onChangeEnd: (value) {
                    _updateOption(option.id, value.round());
                  },
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  option.value.toString(),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBooleanOption(Option option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              option.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Switch(
            value: option.value,
            onChanged: (value) {
              setState(() {
                option.value = value;
              });
              _updateOption(option.id, value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDurationOption(Option option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            option.label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: option.value.toDouble(),
                  min: option.min?.toDouble() ?? 0,
                  max: option.max?.toDouble() ?? 10000,
                  label: '${(option.value / 1000).toStringAsFixed(1)}s',
                  onChanged: (value) {
                    setState(() {
                      option.value = value;
                    });
                  },
                  onChangeEnd: (value) {
                    _updateOption(option.id, value);
                  },
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  '${(option.value / 1000).toStringAsFixed(1)}s',
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 