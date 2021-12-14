import 'package:ceposto/models/restaurant.dart';
import 'dart:convert';

class RestaurantResponse {
  final List<Restaurant> restaurants;

  RestaurantResponse({this.restaurants});

  factory RestaurantResponse.fromJson(Map<String, dynamic> json) =>
      RestaurantResponse(
          restaurants: (json['restaurants'] as List)
              .map((restaurant) => Restaurant.fromJson(restaurant))
              .toList(growable: false));
}
