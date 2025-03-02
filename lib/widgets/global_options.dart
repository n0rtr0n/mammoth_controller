import 'package:flutter/material.dart';
import 'package:mammoth_controller/config_page.dart';
import 'package:mammoth_controller/models/options.dart';

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
  Options? _options;
  String? _errorMessage;
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

  Future<void> _updateOption(String optionId, dynamic value) async {
    if (_baseUrl == null || _options == null) return;

    try {
      await Options.updateOption(_baseUrl!, optionId, value);
      
      // Update local state
      setState(() {
        _options!.options[optionId]?.value = value;
      });
      
      widget.onTransitionUpdated();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update option: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            Text(
              'Global Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Build all options dynamically
            ...options.entries.map((entry) {
              final option = entry.value;
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
                  divisions: ((option.max ?? 100) - (option.min ?? 0)).toInt(),
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
                  divisions: ((option.max ?? 100) - (option.min ?? 0)).toInt(),
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
                
                // Update dependent variables
                if (option.id == 'patternTransitionEnabled') {
                  patternTransitionEnabled = value;
                } else if (option.id == 'colorMaskTransitionEnabled') {
                  colorMaskTransitionEnabled = value;
                }
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
                  divisions: ((option.max ?? 10000) - (option.min ?? 0)).toInt() ~/ 100,
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