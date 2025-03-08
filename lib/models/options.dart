import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mammoth_controller/config_page.dart';

class Option {
  final String id;
  final String label;
  final String type;
  dynamic value;
  final int? min;
  final int? max;

  Option({
    required this.id,
    required this.label,
    required this.type,
    required this.value,
    this.min,
    this.max,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    // Handle type conversion for min and max values
    int? min, max;
    
    if (json['min'] != null) {
      min = json['min'] is int ? json['min'] : json['min'].toInt();
    }
    
    if (json['max'] != null) {
      max = json['max'] is int ? json['max'] : json['max'].toInt();
    }
    
    // Handle value based on type
    dynamic value = json['value'];
    final type = json['type'];
    
    // Ensure correct type for value based on option type
    if (type == 'float' || type == 'duration') {
      value = value is double ? value : value.toDouble();
    } else if (type == 'int') {
      value = value is int ? value : value.toInt();
    } else if (type == 'boolean' || type == 'bool') {
      value = value is bool ? value : (value == 1 || value == '1' || value == 'true');
    }
    // For colorCorrection, we keep the value as a Map
    
    return Option(
      id: json['id'],
      label: json['label'],
      type: json['type'],
      value: value,
      min: min,
      max: max,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }
}

// New class to represent a color correction section
class ColorCorrectionSection {
  final String id;
  final String label;
  double red;
  double green;
  double blue;

  ColorCorrectionSection({
    required this.id,
    required this.label,
    required this.red,
    required this.green,
    required this.blue,
  });

  factory ColorCorrectionSection.fromJson(Map<String, dynamic> json) {
    // Add debug logging
    print('Parsing section: $json');
    
    // Handle possible missing or malformed values
    double red = 100.0;
    double green = 100.0;
    double blue = 100.0;
    
    if (json['red'] != null && json['red'] is Map<String, dynamic>) {
      red = (json['red']['value'] as num?)?.toDouble() ?? 100.0;
    }
    
    if (json['green'] != null && json['green'] is Map<String, dynamic>) {
      green = (json['green']['value'] as num?)?.toDouble() ?? 100.0;
    }
    
    if (json['blue'] != null && json['blue'] is Map<String, dynamic>) {
      blue = (json['blue']['value'] as num?)?.toDouble() ?? 100.0;
    }
    
    return ColorCorrectionSection(
      id: json['id'] as String? ?? 'unknown',
      label: json['label'] as String? ?? 'Unknown',
      red: red,
      green: green,
      blue: blue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'red': {'value': red, 'type': 'float'},
      'green': {'value': green, 'type': 'float'},
      'blue': {'value': blue, 'type': 'float'},
    };
  }
}

class Options {
  final Map<String, Option> options;

  Options({required this.options});

  factory Options.fromJson(Map<String, dynamic> json) {
    final options = <String, Option>{};
    
    json.forEach((key, value) {
      options[key] = Option.fromJson(value);
    });
    
    return Options(options: options);
  }

  static Future<Options> fetchOptions() async {
    final baseUrl = await ConfigPage.getBaseUrl();
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/options'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Options.fromJson(data);
      } else {
        throw Exception('Failed to load options: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching options: $e');
    }
  }

  static Future<void> updateOption(String baseUrl, String optionId, dynamic value) async {
    try {
      await http.put(
        Uri.parse('$baseUrl/options/$optionId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'value': value}),
      );
    } catch (e) {
      throw Exception('Error updating option: $e');
    }
  }

  // Update the method to match the expected API format
  static Future<void> updateColorCorrectionSection(
    String baseUrl, 
    String sectionId, 
    Map<String, dynamic> sectionData
  ) async {
    try {
      // Format the request body according to the expected structure
      final Map<String, dynamic> requestBody = {
        "value": {
          "sections": {
            sectionId: {
              "red": {
                "value": sectionData["red"]["value"]
              },
              "green": {
                "value": sectionData["green"]["value"]
              },
              "blue": {
                "value": sectionData["blue"]["value"]
              }
            }
          }
        }
      };
      
      print('Updating color correction section with: $requestBody');
      
      await http.put(
        Uri.parse('$baseUrl/options/colorCorrection'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );
    } catch (e) {
      throw Exception('Error updating color correction section: $e');
    }
  }

  // Update the enabled state method
  static Future<void> updateColorCorrectionEnabled(
    String baseUrl, 
    bool enabled
  ) async {
    try {
      final Map<String, dynamic> requestBody = {
        "value": {
          "enabled": enabled
        }
      };
      
      await http.put(
        Uri.parse('$baseUrl/options/colorCorrection'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );
    } catch (e) {
      throw Exception('Error updating color correction enabled state: $e');
    }
  }

  // Update the gamma method
  static Future<void> updateColorCorrectionGamma(
    String baseUrl, 
    double gamma
  ) async {
    try {
      final Map<String, dynamic> requestBody = {
        "value": {
          "gamma": {
            "value": gamma
          }
        }
      };
      
      await http.put(
        Uri.parse('$baseUrl/options/colorCorrection'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );
    } catch (e) {
      throw Exception('Error updating gamma value: $e');
    }
  }
} 