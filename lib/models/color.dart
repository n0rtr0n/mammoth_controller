class Color {

  Map<String, dynamic> toJson() {
    return {
      'r': r,
      'g': g,
      'b': b,
    };
  }

  static Color fromJson(Map<String, dynamic> json) {
    return Color(
      r: json['r'] ?? 255,
      g: json['g'] ?? 255,
      b: json['b'] ?? 255,
    );
  }

  int r;
  int g;
  int b;

  Color({
    required this.r,
    required this.g,
    required this.b,
  });
}