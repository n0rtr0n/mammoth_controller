import 'package:mammoth_controller/models/color.dart';

abstract class AdjustableParameter {

  Map<String, dynamic> toJson();

  factory AdjustableParameter.fromJson(String label, Map<String, dynamic> json) {
    if (!json.containsKey('type')) {
      throw Exception('Adjustable parameter does not have a type');
    }
    final type = json['type'];

    switch (type) {
      case 'int':
        final value = json['value'];
        final int min = json['min'];
        final int max = json['max'];
        return IntParameter(label: label, value: value, min: min, max: max);
      case 'float':
        final double value = json['value'].toDouble();
        final double min = json['min'].toDouble();
        final double max = json['max'].toDouble();
        return FloatParameter(label: label, value: value, min: min, max: max);
      case 'bool':
        final bool value = json['value'];
        return BoolParameter(label: label, value: value);
      case 'color':
        final color = json['value'];
        final Color value = Color(
          r: color['r'],
          b: color['b'],
          g: color['g'],
        );
        return ColorParameter(label: label, value: value);
      default:
        print(type);
        throw Exception('Invalid type for AdjustableParameter found');
    }
  }
}

class FloatParameter implements AdjustableParameter {

  @override
  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }

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

  setValue(double newValue) {
    value = newValue;
  }
}

class IntParameter implements AdjustableParameter {
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }
  
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

  setValue(int newValue) {
    value = newValue;
  }
}

class BoolParameter implements AdjustableParameter {

  @override
  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }

  final String label;
  bool value;

  BoolParameter({
    required this.label,
    required this.value,
  });

  setValue(bool newValue) {
    value = newValue;
  }
}

class ColorParameter implements AdjustableParameter {
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'value': value.toJson(),
    };
  }

  final String label;
  final Color value;

  ColorParameter({
    required this.label,
    required this.value,
  });
  
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
