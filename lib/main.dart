import 'package:ceposto/blocs/form/bloc/form_bloc.dart';
import 'package:ceposto/blocs/restaurant/restaurant_bloc.dart';
import 'package:ceposto/network/rest_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'models/restaurant.dart';
import 'welcome_screen/welcome.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'restourant_page.dart';
import 'booking_page.dart';
import 'package:http/http.dart' as http;
import 'package:ceposto/widgets/restaurant_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => FormBloc(),
          ),
          BlocProvider(
            create: (context) => RestaurantBloc(
              restClient: context.read<RestClient>(),
            )..fetchRestaurant(),
          ),
        ],
        child: MaterialApp(
          title: 'CePosto',
          theme: ThemeData(
            appBarTheme: AppBarTheme(brightness: Brightness.dark),
            primaryColor: Colors.black,
          ),
          home: Welcome(),
        ),
      ),
      providers: [RepositoryProvider(create: (_) => RestClient())],
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
      body: BlocBuilder<RestaurantBloc, RestaurantState>(
          builder: (context, state) {
        if (state is ErrorRestaurantState) {
          return _errorRestaurantState(state.error);
        } else if (state is FetchingRestaurantState) {
          return _loadingRestaurantState();
        } else if (state is NoRestaurantState) {
          return _noRestaurantState();
        } else if (state is FetchedRestaurantState) {
          return _listRestaurant(state.restaurant);
        }

        return Container();
      }),
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

  Widget _listRestaurant(List<Restaurant> restaurants) => ListView.builder(
      itemCount: restaurants.length,
      itemBuilder: (context, index) => RestaurantWidget(restaurants[index]));

  Widget _errorRestaurantState(String error) => Center(child: Text(error));

  Widget _noRestaurantState() =>
      Center(child: Text('Non ci sono ristoranti disponibili'));

  Widget _loadingRestaurantState() => Center(
        child: CircularProgressIndicator(),
      );
}
