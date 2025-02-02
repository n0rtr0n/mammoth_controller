import 'package:mammoth_controller/models/parameters.dart';

class Pattern {
  final String id;
  final String label;
  final Map<String,AdjustableParameter> parameters;

  Pattern({
    required this.id,
    required this.label,
    required this.parameters,
  });

  factory Pattern.fromJson(key, Map<String, dynamic> json) {

    final Map<String,AdjustableParameter> parameters = {};

    json['parameters'].forEach((k, parameter) {
      try {
        parameters[k] = AdjustableParameter.fromJson(k, parameter);
      } catch (e){
        print(e);
      }
    });

    final label = json['label'];

    return Pattern(
      id: key,
      label: label,
      parameters: parameters,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> params = {};
    parameters.forEach((key, param) {
      params[key] = param.toJson();
    });
    return {
      'parameters': params,
    };
  }
}