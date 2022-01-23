import 'dart:async';
import 'dart:convert';

import 'package:ceposto/models/restaurant.dart';
import 'package:ceposto/models/user.dart';
import 'package:ceposto/models/user_response.dart';
import 'package:ceposto/network/rest_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class RestaurantPage extends StatefulWidget {
  final Restaurant restaurant;
  RestaurantPage({Key key, @required this.restaurant}) : super(key: key);
  @override
  _RestaurantPageState createState() => _RestaurantPageState(this.restaurant);
}

class _RestaurantPageState extends State<RestaurantPage> {
  final Restaurant restaurant;
  RestClient restClient;
  User user;
  int Nposti;

  _RestaurantPageState(this.restaurant);
  final DateTime now = DateTime.now();
  final DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  List<String> _dynamicChips = ['Health', 'Food', 'Nature'];

  int _counter = 0;
  StreamController _streamController;
  Stream _stream;

  void initState() {
    super.initState();
    getUser().then((data) {
      user = data;
    });

    _streamController = StreamController();
    _stream = _streamController.stream;
  }

  void _incrementCounter() {
    _streamController.sink.add(_counter++);
  }

  void _decrementCounter() {
    _streamController.sink.add(_counter--);
  }

  dynamicChips() {
    return Wrap(
      spacing: 6.0,
      runSpacing: 6.0,
      children: List<Widget>.generate(_dynamicChips.length, (int index) {
        return Chip(
          label: Text(_dynamicChips[index]),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      floatingActionButton: Container(
        width: 300,
        child: ElevatedButton(
          onPressed: () {
            if (Nposti <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Numero di posti non valido")));
            } else {
              postBook(restaurant.id, Nposti,
                  now.millisecondsSinceEpoch.toString(), user.id);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Prenotazione effettuata")));
            }
          },
          child: Text('Prenota un tavolo'),
          style: ElevatedButton.styleFrom(
              primary: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2))),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _titleRestaurant(),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "${restaurant.name}",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: Colors.blueGrey,
                      ),
                      Text(
                        "${restaurant.distance}",
                        style: TextStyle(color: Colors.blueGrey, fontSize: 15),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Column(children: <Widget>[
                          dynamicChips(),
                        ]),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                            child: Icon(
                          Icons.lock_clock,
                          size: 18,
                        )),
                        TextSpan(
                          text: " Orario",
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 20),
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      physics: NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.6,
                      children: [
                        restaurantTimingsData("19:00", true),
                        restaurantTimingsData("19:30", false),
                        restaurantTimingsData("20:30", false),
                        restaurantTimingsData("21:30", false),
                        restaurantTimingsData("21:30", false),
                        restaurantTimingsData("22:30", false),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                            child: Icon(
                          Icons.people_alt,
                          size: 18,
                        )),
                        TextSpan(
                          text: " Persone",
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          height: 30,
                          width: 30,
                          child: InkWell(
                            onTap: _decrementCounter,
                            child: Material(
                              elevation: 5,
                              color: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2)),
                              child: Icon(
                                Icons.remove,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        StreamBuilder(
                            stream: _stream,
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              Nposti = getPosti(snapshot.data);
                              return Text(
                                snapshot.data != null
                                    ? snapshot.data.toString()
                                    : "0",
                              );
                            }),
                        Container(
                          height: 30,
                          width: 30,
                          child: InkWell(
                            onTap: _incrementCounter,
                            child: Material(
                              elevation: 5,
                              color: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2)),
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

Container _titleRestaurant() {
  return Container(
    height: 250,
    decoration: BoxDecoration(
      image: DecorationImage(
          image: NetworkImage("https://source.unsplash.com/6uTQmtqcAzs"),
          fit: BoxFit.cover),
    ),
  );
}

Widget chip(String label, Color color) {
  return Chip(
    labelPadding: EdgeInsets.all(5.0),
    avatar: CircleAvatar(
      backgroundColor: Colors.grey.shade600,
      child: Text(label[0].toUpperCase()),
    ),
    label: Text(
      label,
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    backgroundColor: color,
    elevation: 6.0,
    shadowColor: Colors.grey[60],
    padding: EdgeInsets.all(6.0),
  );
}

postBook(int merchantId, int seatAmount, String date, int requesterId) async {
  FlutterSecureStorage storage = FlutterSecureStorage();
  String token = await storage.read(key: "accessToken");
  try {
    var response = await http.post(
        Uri.parse("https://api-smsimone.cloud.okteto.net/api/prenotation"),
        body: jsonEncode({
          "merchantId": merchantId,
          "seatsAmount": seatAmount,
          "date": date,
          "requesterId": requesterId,
        }),
        headers: {
          "Content-type": "application/json",
          'Accept': 'application/json',
          'access-token': '$token'
        });
  } catch (error) {
    print(error);
  }
}

getPosti(int postiPrenotati) {
  int posti = postiPrenotati;
  return posti;
}

Future<User> getUser() async {
  FlutterSecureStorage storage = FlutterSecureStorage();
  String token = await storage.read(key: "accessToken");

  final response = await http.get(
      Uri.parse('https://api-smsimone.cloud.okteto.net/api/users'),
      headers: {
        "Content-type": "application/json",
        'Accept': 'application/json',
        'access-token': '$token'
      });
  var risposta = response.statusCode;
  var ok1 = jsonDecode(response.body);
  if (response.statusCode == 200) {
    return User.fromJson(ok1);
  } else {
    throw Exception('Non posso caricare User $risposta');
  }
}

Widget restaurantTimingsData(String time, bool isSelected) {
  return isSelected
      ? Container(
          margin: EdgeInsets.only(left: 20, top: 10),
          decoration: BoxDecoration(
            color: Color(0xff107163),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(right: 2),
                child: Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 2),
                child: Text(
                  time,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ],
          ),
        )
      : Container(
          margin: EdgeInsets.only(left: 20, top: 10),
          decoration: BoxDecoration(
            color: Color(0xffEEEEEE),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(right: 2),
                child: Icon(
                  Icons.access_time,
                  color: Colors.black,
                  size: 18,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 2),
                child: Text(
                  time,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ],
          ),
        );
}
