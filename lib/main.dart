import 'package:flutter/material.dart';
import 'dart:convert';
import 'welcome_screen/welcome.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'restourant_page.dart';
import 'booking_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CePosto',
      theme: ThemeData(
        appBarTheme: AppBarTheme(brightness: Brightness.dark),
        primaryColor: Colors.black,
      ),
      home: RestaurantPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Widget>> createList() async {
    List<Widget> items = [];
    String dataString =
        await DefaultAssetBundle.of(context).loadString("assets/data.json");
    List<dynamic> dataJSON = jsonDecode(dataString);

    dataJSON.forEach((object) {
      String finalString = "";
      List<dynamic> dataList = object["placeItems"];
      dataList.forEach((item) {
        finalString = finalString + item + ", ";
      }); // Per prendere dal json gli items dei ristoranti

      items.add(Padding(
          padding: EdgeInsets.all(2.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12, spreadRadius: 2.0, blurRadius: 5.0)
                ]),
            child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(2.0),
                        topRight: Radius.circular(2.0)),
                    child: Image.asset(
                      object["placeImage"],
                      width: 100,
                      height: 125,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(object["placeName"],
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                          child: Text(
                            finalString, //ITEMS RISTORANTI
                            style: TextStyle(fontSize: 12.0),
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "${object["minOrder"]}% ",
                                style: TextStyle(color: Colors.green),
                              ),
                              WidgetSpan(
                                  child: Icon(
                                Icons.people_alt,
                                size: 15,
                              )),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Respond to button press
                          },
                          child: Text('Prenota'),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2))),
                        ),
                      ],
                    ),
                  ),
                ]),
          )));
    });

    return items;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('CePosto'),
      ),
      body: Container(
        child: FutureBuilder(
            initialData: <Widget>[Text("")],
            future: createList(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ListView(
                    primary: false,
                    shrinkWrap: true,
                    children: snapshot.data,
                  ),
                );
              } else {
                return CircularProgressIndicator();
              }
            }),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank),
            label: 'Ristoranti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box_outlined),
            label: 'Profilo',
          ),
        ],
        selectedItemColor: Colors.black,
      ),
    );
  }
}
