import 'dart:convert';

import 'package:ceposto/main.dart';

import 'package:flutter/material.dart';

import 'package:ceposto/network/rest_client.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Welcome extends StatefulWidget {
  @override
  _welcomeState createState() => _welcomeState();
}

class _welcomeState extends State<Welcome> {
  final storage = new FlutterSecureStorage();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.all(0),
                    child: Image.asset(
                      '',
                      height: 350,
                    )),
                _email(),
                _password(),
                _loginButton()
              ]),
        ));
  }

  Widget _email() => Container(
        padding: EdgeInsets.all(15),
        child: TextField(
          controller: _usernameController,
          style: TextStyle(color: Colors.black),
          obscureText: false,
          decoration: InputDecoration(
            border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black)),
            labelText: 'Email',
          ),
        ),
      );

  Widget _password() => Container(
        padding: const EdgeInsets.all(15),
        child: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Password',
          ),
        ),
      );

  Widget _loginButton() => Container(
        padding: const EdgeInsets.all(15),
        child: ElevatedButton(
          onPressed: () {
            login();
          },
          child: const Text('Accedi'),
          style: ElevatedButton.styleFrom(
              primary: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2))),
        ),
      );

  Future<void> login() async {
    if (_passwordController.text.isNotEmpty &&
        _usernameController.text.isNotEmpty) {
      var response = await http.post(
          Uri.parse('https://api-smsimone.cloud.okteto.net/api/auth/login'),
          body: jsonEncode({
            "username": _usernameController.text,
            "password": _passwordController.text,
          }),
          headers: {
            'Content-type': 'application/json',
            'Authorization': 'Bearer'
          });

      var zio = response.statusCode;

      if (response.statusCode == 200) {
        Map<String, dynamic> jResponse = json.decode(response.body);

        await storage.write(
            key: "accessToken", value: jResponse["accessToken"]);

        print('LOGIN TOKEN --- ' + jResponse['accessToken']);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MyHomePage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Credenziali non valide $zio")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hai lasciato qualcosa di vuoto!")));
    }
  }
}
