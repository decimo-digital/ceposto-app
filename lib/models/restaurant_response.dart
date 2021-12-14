import 'package:ceposto/models/restaurant.dart';

class RestaurantResponse {
  final List<Restaurant> restaurants;

  RestaurantResponse({this.restaurants});

  factory RestaurantResponse.fromJson(List<dynamic> json) => RestaurantResponse(
        restaurants:
            json.map((restaurant) => Restaurant.fromJson(restaurant)).toList(),
      );
}
