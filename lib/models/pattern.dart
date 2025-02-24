import 'package:mammoth_controller/models/parameters.dart';

class Pattern {
  final String id;
  final String label;
  final Map<String, AdjustableParameter>? parameters;

  Pattern({
    required this.id,
    required this.label,
    this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {
      'parameters': parameters?.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }

  factory Pattern.fromJson(String id, Map<String, dynamic> json) {
    final parameters = <String, AdjustableParameter>{};
    
    if (json['parameters'] != null) {
      (json['parameters'] as Map<String, dynamic>).forEach((key, value) {
        parameters[key] = AdjustableParameter.fromJson(key, value);
      });
    }

    return Pattern(
      id: id,
      label: json['label'],
      parameters: parameters,
    );
  }
}

class PatternCollection {
  final Map<String, Pattern> patterns;
  final Map<String, Pattern> colorMasks;

  PatternCollection({
    required this.patterns,
    required this.colorMasks,
  });

  factory PatternCollection.fromJson(Map<String, dynamic> json) {
    final patterns = <String, Pattern>{};
    final colorMasks = <String, Pattern>{};

    if (json['patterns'] != null) {
      (json['patterns'] as Map<String, dynamic>).forEach((key, value) {
        patterns[key] = Pattern.fromJson(key, value);
      });
    }

    if (json['colorMasks'] != null) {
      (json['colorMasks'] as Map<String, dynamic>).forEach((key, value) {
        colorMasks[key] = Pattern.fromJson(key, value);
      });
    }

    return PatternCollection(
      patterns: patterns,
      colorMasks: colorMasks,
    );
  }
}