import '../restourant_page.dart';
import 'package:flutter/material.dart';
import 'package:ceposto/models/restaurant.dart';

class RestaurantWidget extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantWidget(this.restaurant, {Key, key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                    '',
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
                      Text(restaurant.name,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                        child: Text(
                          'ITEMs', //ITEMS RISTORANTI
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "${restaurant.distance}KM ",
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
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RestaurantPage(
                                        restaurant: restaurant,
                                      )));
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
        ));
  }
}
