import 'dart:convert';

import 'package:ceposto/models/restaurant_response.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class RestClient {
  FlutterSecureStorage storage = FlutterSecureStorage();
  Future<RestaurantResponse> RestaurantRes() async {
    String token = await storage.read(
        key: "accessToken"); // legge il token del login sullo storage

    final response = await http.get(
        Uri.parse('https://api-smsimone.cloud.okteto.net/api/merchant'),
        headers: {
          "Content-type": "application/json",
          'Accept': 'application/json',
          'access-token': '$token'
        });
    var risposta = response.statusCode;
    var ok = jsonDecode(response.body) as List<dynamic>;
    print('IL TIPO= ' + ok.runtimeType.toString());
    if (response.statusCode == 200) {
      return RestaurantResponse.fromJson(ok);
    } else {
      throw Exception('Non posso caricare Ristoranti $risposta');
    }
  }
}
