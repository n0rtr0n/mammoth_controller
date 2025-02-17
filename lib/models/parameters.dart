import 'package:mammoth_controller/models/color.dart';

abstract class AdjustableParameter {
  String get label;
  Map<String, dynamic> toJson();

  // Add a generic setValue method
  void setValue(dynamic value);

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
