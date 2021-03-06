import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:ceposto/models/restaurant.dart';
import 'package:ceposto/models/user.dart';
import 'package:ceposto/network/rest_client.dart';
import 'package:ceposto/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class RestaurantPage extends StatefulWidget {
  final Restaurant restaurant;
  RestaurantPage({Key key, @required this.restaurant}) : super(key: key);
  @override
  _RestaurantPageState createState() => _RestaurantPageState(this.restaurant);
}

class _RestaurantPageState extends State<RestaurantPage> {
  final Restaurant restaurant;
  RestClient restClient;
  int Nposti;

  _RestaurantPageState(this.restaurant);
  final DateTime now = DateTime.now();
  final DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  List<String> _dynamicChips = ['Health', 'Food', 'Nature'];

  int _counter = 0;
  StreamController _streamController;
  Stream<dynamic> _stream;

  void initState() {
    super.initState();

    _streamController = StreamController();
    _stream = _streamController.stream;
  }

  void _incrementCounter() {
    _streamController.sink.add(++_counter);
  }

  void _decrementCounter() {
    _streamController.sink.add(--_counter);
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
        child: FutureBuilder<User>(
            future: getUser(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              return ElevatedButton(
                onPressed: user == null
                    ? null
                    : () async {
                        if (_counter <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Numero di posti non valido")));
                        } else if (_counter <= restaurant.freeSeats) {
                          final result = await postBook(
                            restaurant.id,
                            Nposti,
                            now.millisecondsSinceEpoch.toString(),
                            user.id,
                          );
                          if (result) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Prenotazione effettuata",
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "C'?? stato qualche problema ad effettuare la prenotazione",
                                ),
                              ),
                            );
                          }
                        }
                      },
                child: Text('Prenota un tavolo'),
                style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2))),
              );
            }),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _titleRestaurant(this.restaurant),
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
                            onTap: () {
                              if (Nposti > 1) _decrementCounter();
                            },
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
                        StreamBuilder<dynamic>(
                          stream: _stream,
                          initialData: 0,
                          builder: (context, snapshot) {
                            final data = snapshot.data;
                            assert(data != null);
                            Nposti = getPosti(snapshot.data);
                            return Text(data.toString());
                          },
                        ),
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

Widget _titleRestaurant(Restaurant restaurant) {
  String img = restaurant.image;

  if (img == null) {
    return Image.asset(
      'images/pizza.jpg',
      fit: BoxFit.cover,
      height: 250,
    );
  } else {
    return Image.memory(
      Base64Decoder().convert(img),
      fit: BoxFit.cover,
      height: 250,
    );
  }
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

Future<bool> postBook(
  int merchantId,
  int seatAmount,
  String date,
  int requesterId,
) async {
  /*FlutterSecureStorage storage = FlutterSecureStorage();*/
  /*String token = await storage.read(key: "accessToken");*/
  Preferences preferences = await Preferences.instance;
  final token = await preferences.getFromKey("accessToken");

  var response = await http.post(
      Uri.parse(
          "https://api-dbperservice-smsimone.cloud.okteto.net/api/prenotation"),
      body: jsonEncode({
        "merchantId": merchantId,
        "seatsAmount": seatAmount,
        "date": date,
        "requesterId": requesterId,
      }),
      headers: {
        "Content-type": "application/json",
        'Accept': 'application/json',
        'access-token': token
      }).onError((error, stackTrace) {
    debugPrint('Failed to post on prenotation: $error');
    debugPrintStack(stackTrace: stackTrace);
    return null;
  });

  return response.statusCode == 200;
}

getPosti(int postiPrenotati) {
  int posti = postiPrenotati;
  return posti;
}

Future<User> getUser() async {
  /*FlutterSecureStorage storage = FlutterSecureStorage();
  String token = await storage.read(key: "accessToken");*/
  Preferences preferences = await Preferences.instance;
  String token = await preferences.getFromKey("accessToken");
  final response = await http.get(
      Uri.parse('https://api-dbperservice-smsimone.cloud.okteto.net/api/users'),
      headers: {
        "Content-type": "application/json",
        'Accept': 'application/json',
        'access-token': token,
      });
  var responseCode = response.statusCode;
  var responseDecode = jsonDecode(response.body);
  if (response.statusCode == 200) {
    return User.fromJson(responseDecode);
  } else {
    throw Exception('Non posso caricare User $responseCode');
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
