import 'dart:convert';

import 'package:ceposto/models/restaurant.dart';
import 'package:ceposto/models/restaurant_response.dart';
import 'package:ceposto/utils/preferences.dart';
import 'package:http/http.dart' as http;

class RestClient {
  Future<RestaurantResponse> RestaurantRes() async {
    Preferences preferences = await Preferences.instance;

    /// legge il token del login sullo storage
    String token = await preferences.getFromKey("accessToken");
    final response = await http.get(
        Uri.parse(
            'https://api-dbperservice-smsimone.cloud.okteto.net/api/merchant'),
        headers: {
          "Content-type": "application/json",
          'Accept': 'application/json',
          'access-token': token,
        });

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body) as List<dynamic>;
      return RestaurantResponse.fromJson(responseBody);
    } else {
      throw Exception('Non posso caricare Ristoranti ${response.statusCode}');
    }
  }

  static Future<Restaurant> getRestaurantData(int restaurantId) async {
    Preferences preferences = await Preferences.instance;

    /// legge il token del login sullo storage
    String token = await preferences.getFromKey("accessToken");

    final response = await http.get(
        Uri.parse(
            'https://api-dbperservice-smsimone.cloud.okteto.net/api/merchant/$restaurantId/data'),
        headers: {
          "Content-type": "application/json",
          'Accept': 'application/json',
          'access-token': token,
        });

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      return Restaurant.fromJson(responseBody);
    } else {
      throw Exception('Non posso caricare Ristoranti ${response.statusCode}');
    }
  }
}
