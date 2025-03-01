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
    return Option(
      id: json['id'],
      label: json['label'],
      type: json['type'],
      value: json['value'],
      min: json['min'],
      max: json['max'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
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
} 