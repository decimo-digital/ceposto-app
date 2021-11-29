import 'package:ceposto/models/restaurant.dart';
import 'package:ceposto/models/restaurant_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class RestClient {
  Future<RestaurantResponse> RestaurantRes() async {
    final response = await http.get(
        Uri.parse('api-smsimone.cloud.okteto.net/api/merchant/1/data'),
        headers: {
          // aggiungere accessToken
          HttpHeaders.authorizationHeader:
              'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJleHAiOiIxNjM3NjcwMzE5MDYzIiwiaWF0IjoiMTYzNzY2MzExOTA2MyIsInVzZXJuYW1lIjoic3RyaW5nIn0=.df873cfdfec310b80a58cc82ba7b091e7eeacbe7612a9cee17b1ec0b1d4694ca15497b4f26190adce23f2a3a581ac1aed6880916568f9ac43b3393e7186007bc'
        });

    if (response.statusCode == 200) {
      return RestaurantResponse().fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Non posso caricare Ristoranti');
    }
  }
}
