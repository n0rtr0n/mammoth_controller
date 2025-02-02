import 'dart:convert';
import 'package:mammoth_controller/models/parameters.dart';
import 'package:mammoth_controller/widgets/bool_parameter.dart';
import 'package:mammoth_controller/widgets/color_parameter.dart';
import 'package:mammoth_controller/widgets/float_parameter.dart';
import 'package:mammoth_controller/widgets/int_parameter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mammoth_controller/models/pattern.dart';

class PatternSelector extends StatefulWidget {
  const PatternSelector({super.key});

  @override
  State<PatternSelector> createState() => _PatternSelectorState();
}

class _PatternSelectorState extends State<PatternSelector> {
  List<Pattern> patterns = [];
  final baseURL = 'http://127.0.0.1:8008';

  Future<http.Response> _updatePattern(int index, Pattern pattern) {
    final body = jsonEncode(pattern.toJson());
    print(body);
    return http.put(
      Uri.parse('$baseURL/patterns/${pattern.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
  }

  Future<void> _fetchPatterns() async {
    try {
      final response = await http.get(Uri.parse('$baseURL/patterns'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final Map<String, dynamic> patternsData = data['patterns'];
        final List<Pattern> fetchedPatterns = [];
        patternsData.forEach((key, pattern) {
          fetchedPatterns.add(Pattern.fromJson(key, pattern));
        });

        setState(() {
          patterns = fetchedPatterns;
        });
      } else {
        throw Exception('Failed to fetch patterns');
      }
    } catch (e) {
      print('caught error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: patterns.length,
            itemBuilder: (context, index) {
              final currentPattern = patterns[index];
              final parameters = [];
              currentPattern.parameters
                  .forEach((key, item) => parameters.add(item));
              return Card(
                child: Column(
                  children: [
                    Text(
                      patterns[index].label,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: 4,
                      height: 4,
                    ),
                    ListView.builder(
                      itemCount: parameters.length,
                      itemBuilder: (context, index) {
                        final AdjustableParameter param = parameters[index];
                        final Widget widget;
                        if (param is FloatParameter) {
                          void onParameterUpdate(double value) {
                            setState(() {
                              parameters[index].setValue(value);
                            });
                          }

                          widget = FloatParameterWidget(
                            parameter: param,
                            onParameterUpdate: onParameterUpdate,
                          );
                        } else if (param is BoolParameter) {
                          void onParameterUpdate(bool value) {
                            setState(() {
                              parameters[index].setValue(value);
                            });
                          }

                          widget = BoolParameterWidget(
                            parameter: param,
                            onParameterUpdate: onParameterUpdate,
                          );
                        } else if (param is IntParameter) {
                          void onParameterUpdate(double value) {
                            setState(() {
                              parameters[index].setValue(value.toInt());
                            });
                          }

                          widget = IntParameterWidget(
                            parameter: param,
                            onParameterUpdate: onParameterUpdate,
                          );
                        } else if (param is ColorParameter) {
                          void onRedParameterUpdate(double value) {
                            setState(() {
                              parameters[index].setRed(value.toInt());
                            });
                          }

                          void onGreenParameterUpdate(double value) {
                            setState(() {
                              parameters[index].setGreen(value.toInt());
                            });
                          }

                          void onBlueParameterUpdate(double value) {
                            setState(() {
                              parameters[index].setBlue(value.toInt());
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
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _updatePattern(index, currentPattern);
                        },
                        child: const Text("Update pattern"),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        FetchPatternsButton(
          onFetchPatterns: _fetchPatterns,
        ),
      ],
    );
  }
}

class FetchPatternsButton extends StatelessWidget {
  const FetchPatternsButton({
    super.key,
    required this.onFetchPatterns,
  });

  final void Function() onFetchPatterns;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onFetchPatterns,
      child: const Text('Fetch patterns'),
    );
  }
}
