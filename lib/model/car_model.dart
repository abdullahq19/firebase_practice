import 'dart:convert';

class Car {
  String make;
  int model;
  String type;
  String color;
  Car({
    required this.make,
    required this.model,
    required this.type,
    required this.color,
  });

  Car copyWith({
    String? make,
    int? model,
    String? type,
    String? color,
  }) {
    return Car(
      make: make ?? this.make,
      model: model ?? this.model,
      type: type ?? this.type,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'make': make,
      'model': model,
      'type': type,
      'color': color,
    };
  }

  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      make: map['make'] as String,
      model: map['model'] as int,
      type: map['type'] as String,
      color: map['color'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Car.fromJson(String source) =>
      Car.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Car(make: $make, model: $model, type: $type, color: $color)';
  }

  @override
  bool operator ==(covariant Car other) {
    if (identical(this, other)) return true;

    return other.make == make &&
        other.model == model &&
        other.type == type &&
        other.color == color;
  }

  @override
  int get hashCode {
    return make.hashCode ^ model.hashCode ^ type.hashCode ^ color.hashCode;
  }
}
