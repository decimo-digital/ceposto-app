import 'package:ceposto/models/restaurant_response.dart';

class Restaurant {
  final String name;
  final double distance;
  final String owner;

  Restaurant({this.name, this.distance, this.owner});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
        name: json['name'] as String,
        distance: json['distance'] as double,
        owner: json['owner'] as String);
  }
}
