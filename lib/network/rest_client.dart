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
        Uri.parse('https://api-smsimone.cloud.okteto.net/api/merchant'),
        headers: {
          "Content-type": "application/json",
          'Accept': 'application/json',
          'access-token': '$token'
        });
    var risposta = response.statusCode;
    var ok = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return RestaurantResponse.fromJson(ok);
    } else {
      throw Exception('Non posso caricare Ristoranti $risposta token $token');
    }
  }
}
