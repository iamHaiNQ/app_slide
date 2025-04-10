class Background {
  final String type;
  final String color;

  Background({required this.type, required this.color});

  factory Background.fromJson(Map<String, dynamic> json) {
    return Background(
      type: json['type'],
      color: json['color'],
    );
  }
}