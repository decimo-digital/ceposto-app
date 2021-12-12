import 'package:ceposto/models/response_login.dart';
import 'package:ceposto/models/restaurant.dart';
import 'package:ceposto/welcome_screen/welcome.dart';
import 'package:ceposto/models/restaurant_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RestClient {
  FlutterSecureStorage storage = FlutterSecureStorage();
  Future<RestaurantResponse> RestaurantRes() async {
    String token = await storage.read(key: "accessToken");

    final response = await http.get(
        Uri.parse('https://api-smsimone.cloud.okteto.net/api/merchant/1/data'),
        headers: {
          // aggiungere accessToken
          "Content-type": "application/json",
          "Authorization": "Bearer $token"
        });
    var risposta = response.statusCode;
    if (response.statusCode == 200) {
      return RestaurantResponse().fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Non posso caricare Ristoranti $risposta token $token');
    }
  }
}
