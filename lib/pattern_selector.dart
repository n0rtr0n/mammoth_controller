import 'dart:convert';
import 'package:mammoth_controller/config_page.dart';
import 'package:mammoth_controller/models/parameters.dart';
import 'package:mammoth_controller/widgets/bool_parameter.dart';
import 'package:mammoth_controller/widgets/color_parameter.dart';
import 'package:mammoth_controller/widgets/float_parameter.dart';
import 'package:mammoth_controller/widgets/int_parameter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mammoth_controller/models/pattern.dart' as models;
import 'package:mammoth_controller/widgets/global_options.dart';

class PatternSelector extends StatefulWidget {
  const PatternSelector({
    super.key,
    required this.patterns,
    required this.colorMasks,
    required this.onPatternUpdated,
    required this.onColorMaskUpdated,
  });

  final List<models.Pattern> patterns;
  final Map<String, models.Pattern> colorMasks;
  final void Function(String) onPatternUpdated;
  final void Function(String) onColorMaskUpdated;

  @override
  State<PatternSelector> createState() => _PatternSelectorState();
}

class _PatternSelectorState extends State<PatternSelector> with SingleTickerProviderStateMixin {
  String? baseURL;
  late TabController _tabController;
  
  @override 
  void initState() {
    super.initState();
    _loadBaseUrl();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBaseUrl() async {
    final url = await ConfigPage.getBaseUrl();
    setState(() {
      baseURL = url;
    });
  }

  Future<void> _updatePattern(String id, models.Pattern pattern) async {
    if (baseURL == null) return;
    
    try {
      final response = await http.put(
        Uri.parse('$baseURL/patterns/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(pattern.toJson()),
      );
      
      if (response.statusCode == 200) {
        widget.onPatternUpdated(pattern.label);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update pattern'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating pattern'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.color_lens),
                text: "Color Masks",
              ),
              Tab(
                icon: Icon(Icons.auto_awesome),
                text: "Patterns",
              ),
              Tab(
                icon: Icon(Icons.settings),
                text: "Global Options",
              ),
            ],
            labelColor: Theme.of(context).colorScheme.onPrimaryContainer,
            indicatorColor: Theme.of(context).colorScheme.onPrimaryContainer,
            dividerColor: Colors.transparent,
          ),
        ),
        
        // Tab Bar View
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Color Masks Tab
              _buildColorMasksTab(),
              
              // Patterns Tab
              _buildPatternsTab(),
              
              // Global Options Tab
              _buildGlobalOptionsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatternCard(models.Pattern pattern, Function(String, models.Pattern) updateFunction, String buttonText) {
    final parameters = <AdjustableParameter>[];
    
    pattern.parameters?.forEach((key, item) {
      parameters.add(item);
    });
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Text(
              pattern.label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Parameters
          if (parameters.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.separated(
                itemCount: parameters.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final param = parameters[index];
                  return _buildParameterWidget(param);
                },
              ),
            ),
          
          // Update button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ElevatedButton(
              onPressed: () => updateFunction(pattern.id, pattern),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterWidget(AdjustableParameter param) {
    Widget paramWidget;
    
    if (param is FloatParameter) {
      void onParameterUpdate(double value) {
        setState(() {
          param.setValue(value);
        });
      }

      paramWidget = FloatParameterWidget(
        parameter: param,
        onParameterUpdate: onParameterUpdate,
      );
    } else if (param is BoolParameter) {
      void onParameterUpdate(bool value) {
        setState(() {
          param.setValue(value);
        });
      }

      paramWidget = BoolParameterWidget(
        parameter: param,
        onParameterUpdate: onParameterUpdate,
      );
    } else if (param is IntParameter) {
      void onParameterUpdate(double value) {
        setState(() {
          param.setValue(value.toInt());
        });
      }

      paramWidget = IntParameterWidget(
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

      paramWidget = ColorParameterWidget(
        parameter: param,
        onRedParameterUpdate: onRedParameterUpdate,
        onGreenParameterUpdate: onGreenParameterUpdate,
        onBlueParameterUpdate: onBlueParameterUpdate,
      );
    } else {
      paramWidget = Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "Unsupported parameter: ${param.label}",
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      );
    }

    return paramWidget;
  }

  Widget _buildPatternsTab() {
    return ListView.builder(
      itemCount: widget.patterns.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final pattern = widget.patterns[index];
        return _buildPatternCard(pattern, _updatePattern, "Update Pattern");
      },
    );
  }

  Widget _buildColorMasksTab() {
    return ListView.builder(
      itemCount: widget.colorMasks.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final entry = widget.colorMasks.entries.elementAt(index);
        return _buildPatternCard(entry.value, _updateColorMask, "Update Mask");
      },
    );
  }

  Future<void> _updateColorMask(String id, models.Pattern mask) async {
    if (baseURL == null) return;
    
    try {
      final response = await http.put(
        Uri.parse('$baseURL/colorMasks/$id'),
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

  Widget _buildGlobalOptionsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: GlobalOptions(
          onTransitionUpdated: () {
            // Handle transition update if needed
          },
        ),
      ),
    );
  }
}
