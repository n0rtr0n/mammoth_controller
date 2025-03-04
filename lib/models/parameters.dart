import 'package:mammoth_controller/models/color.dart';

abstract class AdjustableParameter {
  String get label;
  Map<String, dynamic> toJson();

  // Add a generic setValue method
  void setValue(dynamic value);

  factory AdjustableParameter.fromJson(String id, Map<String, dynamic> json) {
    final type = json['type'];
    
    switch (type) {
      case 'float':
        return FloatParameter(
          label: json['label'] ?? id,
          value: (json['value'] ?? 0.0).toDouble(),
          min: (json['min'] ?? 0.0).toDouble(),
          max: (json['max'] ?? 1.0).toDouble(),
        );
      case 'int':
        return IntParameter(
          label: json['label'] ?? id,
          value: (json['value'] ?? 0) as int,
          min: (json['min'] ?? 0) as int,
          max: (json['max'] ?? 100) as int,
        );
      case 'boolean':
      case 'bool':
        return BoolParameter(
          label: json['label'] ?? id,
          value: json['value'] ?? false,
        );
      case 'color':
        return ColorParameter(
          label: json['label'] ?? id,
          value: Color.fromJson(json['value'] ?? {'r': 255, 'g': 255, 'b': 255}),
        );
      case 'duration':
        // Add support for duration type
        return FloatParameter(
          label: json['label'] ?? id,
          value: (json['value'] ?? 0.0).toDouble(),
          min: (json['min'] ?? 0.0).toDouble(),
          max: (json['max'] ?? 10000.0).toDouble(),
        );
      default:
        throw Exception('Unknown parameter type: $type');
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
