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

  Widget _buildDurationOption(Option option, bool enabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          option.label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: enabled 
                ? null 
                : Theme.of(context).disabledColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: option.value.toDouble(),
                min: option.min?.toDouble() ?? 0,
                max: option.max?.toDouble() ?? 10000,
                divisions: ((option.max ?? 10000) ~/ 100),
                label: '${option.value}ms',
                onChanged: enabled 
                    ? (value) {
                        setState(() {
                          option.value = value.toInt();
                        });
                      }
                    : null,
                onChangeEnd: enabled 
                    ? (value) {
                        _updateOption(option.id, value.toInt());
                      }
                    : null,
              ),
            ),
            SizedBox(
              width: 80,
              child: Text(
                '${option.value}ms',
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: enabled 
                      ? null 
                      : Theme.of(context).disabledColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBooleanOption(Option option) {
    return Row(
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
    );
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
    final patternTransitionEnabled = options['patternTransitionEnabled']?.value ?? false;
    final colorMaskTransitionEnabled = options['colorMaskTransitionEnabled']?.value ?? false;
    
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
            
            // Pattern Transition Options
            if (options.containsKey('patternTransitionEnabled'))
              _buildBooleanOption(options['patternTransitionEnabled']!),
            
            if (options.containsKey('patternTransitionDuration'))
              _buildDurationOption(
                options['patternTransitionDuration']!, 
                patternTransitionEnabled
              ),
            
            const SizedBox(height: 16),
            
            // Color Mask Transition Options
            if (options.containsKey('colorMaskTransitionEnabled'))
              _buildBooleanOption(options['colorMaskTransitionEnabled']!),
            
            if (options.containsKey('colorMaskTransitionDuration'))
              _buildDurationOption(
                options['colorMaskTransitionDuration']!,
                colorMaskTransitionEnabled
              ),
          ],
        ),
      ),
    );
  }
} 