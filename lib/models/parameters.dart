import 'package:mammoth_controller/models/color.dart';

abstract class AdjustableParameter {
  String get label;
  Map<String, dynamic> toJson();

  // Add a generic setValue method
  void setValue(dynamic value);

  factory AdjustableParameter.fromJson(String label, Map<String, dynamic> json) {
    print('Creating parameter for label: $label with json: $json'); // Debug log

    if (!json.containsKey('type')) {
      print('Parameter missing type: $json'); // Debug log
      throw Exception('Adjustable parameter does not have a type');
    }
    final type = json['type'];

    try {
      switch (type) {
        case 'int':
          final value = json['value'] as int;
          final min = json['min'] as int;
          final max = json['max'] as int;
          return IntParameter(label: label, value: value, min: min, max: max);
        case 'float':
          final value = (json['value'] as num).toDouble();
          final min = (json['min'] as num).toDouble();
          final max = (json['max'] as num).toDouble();
          return FloatParameter(label: label, value: value, min: min, max: max);
        case 'bool':
          final value = json['value'] as bool;
          return BoolParameter(label: label, value: value);
        case 'color':
          final color = json['value'] as Map<String, dynamic>;
          final Color value = Color(
            r: color['r'] as int,
            b: color['b'] as int,
            g: color['g'] as int,
          );
          return ColorParameter(label: label, value: value);
        default:
          print('Unknown parameter type: $type'); // Debug log
          throw Exception('Invalid type for AdjustableParameter found: $type');
      }
    } catch (e) {
      print('Error parsing parameter $label: $e'); // Debug log
      rethrow;
    }
  }
}

class FloatParameter implements AdjustableParameter {
  @override
  final String label;
  final double min;
  final double max;
  double value;

  FloatParameter({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
  });

  @override
  void setValue(dynamic newValue) {
    if (newValue is double) {
      value = newValue;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }
}

class IntParameter implements AdjustableParameter {
  @override
  final String label;
  final int min;
  final int max;
  int value;

  IntParameter({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
  });

  @override
  void setValue(dynamic newValue) {
    if (newValue is int) {
      value = newValue;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }
}

class BoolParameter implements AdjustableParameter {
  @override
  final String label;
  bool value;

  BoolParameter({
    required this.label,
    required this.value,
  });

  @override
  void setValue(dynamic newValue) {
    if (newValue is bool) {
      value = newValue;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }
}

class ColorParameter implements AdjustableParameter {
  @override
  final String label;
  final Color value;

  ColorParameter({
    required this.label,
    required this.value,
  });

  @override
  void setValue(dynamic newValue) {
    throw UnimplementedError('ColorParameter uses setRed/setGreen/setBlue instead');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'value': value.toJson(),
    };
  }
  
  setRed(int newValue) {
    value.r = newValue;
  }
  setGreen(int newValue) {
    value.g = newValue;
  }
  setBlue(int newValue) {
    value.b = newValue;
  }
}
