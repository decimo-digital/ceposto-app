import 'package:ceposto/models/response_login.dart';
import 'package:ceposto/models/restaurant.dart';
import 'package:ceposto/models/restaurant_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserRepository {
  var loginUrl = 'https://api-smsimone.cloud.okteto.net/api/auth/login';

  Future<bool> hasToken() async {
    var value = await storage.read(key: 'token');
    if (value != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> persistToken(String token) async {
    await storage.write(key: 'token', value: token);
  }

  Future<void> deleteToken() async {
    storage.delete(key: 'token');
    storage.deleteAll();
  }

  Future<String> login(String email, String password) async {
    var jsonResponse;
    final response = await http.post(
        Uri.parse('https://api-smsimone.cloud.okteto.net/api/auth/login'),
        body: {
          "email": email,
          "password": password,
        });
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
    }
  }
}
