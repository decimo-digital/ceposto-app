import 'package:ceposto/models/response_login.dart';
import 'package:ceposto/models/restaurant.dart';
import 'package:ceposto/models/restaurant_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RestClient {
  Future<RestaurantResponse> RestaurantRes() async {
    final response = await http.get(
        Uri.parse('api-smsimone.cloud.okteto.net/api/merchant/1/data'),
        headers: {
          // aggiungere accessToken
          HttpHeaders.authorizationHeader:
              'accessToken' // devo inserire accessToken
        });

    if (response.statusCode == 200) {
      return RestaurantResponse().fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Non posso caricare Ristoranti');
    }
  }
}
