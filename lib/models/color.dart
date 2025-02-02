class Color {

  Map<String, dynamic> toJson() {
    return {
      'r': r,
      'g': g,
      'b': b,
    };
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