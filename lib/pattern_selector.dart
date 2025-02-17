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
import 'package:sticky_headers/sticky_headers.dart';

class PatternSelector extends StatefulWidget {
  const PatternSelector({
    super.key,
    required this.patterns,
  });

  final List<models.Pattern> patterns;

  @override
  State<PatternSelector> createState() => _PatternSelectorState();
}

class _PatternSelectorState extends State<PatternSelector> {
  String? baseURL;

  @override 
  void initState() {
    super.initState();
    _loadBaseUrl();
  }

  Future<void> _loadBaseUrl() async {
    final url = await ConfigPage.getBaseUrl();
    setState(() {
      baseURL = url;
    });
  }

  Future<http.Response> _updatePattern(int index, models.Pattern pattern) {
    final body = jsonEncode(pattern.toJson());
    return http.put(
      Uri.parse('$baseURL/patterns/${pattern.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.patterns.length,
      itemBuilder: (context, patternIndex) {
        final currentPattern = widget.patterns[patternIndex];
        final parameters = <AdjustableParameter>[];
        print('Pattern: ${currentPattern.label}');
        print('Parameters: ${currentPattern.parameters}');
        currentPattern.parameters?.forEach((key, item) {
          print('Parameter item: $item');
          parameters.add(item);
        });
        
        return Card(
          child: StickyHeader(
            header: Container(
              color: Theme.of(context).colorScheme.secondaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    currentPattern.label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            content: Column(
              children: [
                if (parameters.isNotEmpty) ListView.builder(
                  itemCount: parameters.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final param = parameters[index];
                    final Widget widget;
                    if (param is FloatParameter) {
                      void onParameterUpdate(double value) {
                        setState(() {
                          (param as FloatParameter).setValue(value);
                        });
                      }

                      widget = FloatParameterWidget(
                        parameter: param,
                        onParameterUpdate: onParameterUpdate,
                      );
                    } else if (param is BoolParameter) {
                      void onParameterUpdate(bool value) {
                        setState(() {
                          (param as BoolParameter).setValue(value);
                        });
                      }

                      widget = BoolParameterWidget(
                        parameter: param,
                        onParameterUpdate: onParameterUpdate,
                      );
                    } else if (param is IntParameter) {
                      void onParameterUpdate(double value) {
                        setState(() {
                          (param as IntParameter).setValue(value.toInt());
                        });
                      }

                      widget = IntParameterWidget(
                        parameter: param,
                        onParameterUpdate: onParameterUpdate,
                      );
                    } else if (param is ColorParameter) {
                      void onRedParameterUpdate(double value) {
                        setState(() {
                          (param as ColorParameter).setRed(value.toInt());
                        });
                      }

                      void onGreenParameterUpdate(double value) {
                        setState(() {
                          (param as ColorParameter).setGreen(value.toInt());
                        });
                      }

                      void onBlueParameterUpdate(double value) {
                        setState(() {
                          (param as ColorParameter).setBlue(value.toInt());
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
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _updatePattern(patternIndex, currentPattern);
                    },
                    child: const Text("Update pattern"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
