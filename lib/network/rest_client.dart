import 'dart:convert';

import 'package:ceposto/models/restaurant_response.dart';
import 'package:ceposto/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ceposto/utils/preferences.dart';

class RestClient {
  Future<RestaurantResponse> RestaurantRes() async {
    Preferences preferences = await Preferences.instance;
    /*String token = await storage.read(
        key: "accessToken");*/
    Future<String> token = preferences
        .getFromKey("accessToken"); // legge il token del login sullo storage

    final response = await http.get(
        Uri.parse(
            'https://api-dbperservice-smsimone.cloud.okteto.net/api/merchant'),
        headers: {
          "Content-type": "application/json",
          'Accept': 'application/json',
          'access-token': '$token'
        });
    var risposta = response.statusCode;
    var ok = jsonDecode(response.body) as List<dynamic>;
    if (response.statusCode == 200) {
      return RestaurantResponse.fromJson(ok);
    } else {
      throw Exception('Non posso caricare Ristoranti $risposta');
    }
  }
}
