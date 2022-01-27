import 'dart:convert';

import 'package:ceposto/models/restaurant.dart';
import 'package:ceposto/network/rest_client.dart';
import 'package:flutter/material.dart';

import '../restourant_page.dart';

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
                SizedBox(
                  height: 125,
                  width: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(2.0),
                      topRight: Radius.circular(2.0),
                    ),
                    child: _imageRestaurant(this.restaurant),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        restaurant.name ?? '---',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Visibility(
                        maintainSize: true,
                        maintainState: true,
                        maintainAnimation: true,
                        visible: restaurant.cuisineType != null,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                          child: Text(
                            "${restaurant.cuisineType} ", //ITEMS RISTORANTI
                            style: TextStyle(fontSize: 12.0),
                          ),
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "${100 - restaurant.occupancyRate} % ",
                              style: TextStyle(color: Colors.green),
                            ),
                            WidgetSpan(
                              child: Icon(
                                Icons.people_alt,
                                size: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final restaurantData =
                              await RestClient.getRestaurantData(
                            restaurant.id,
                          );
                          // Respond to button press
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestaurantPage(
                                restaurant: restaurantData,
                              ),
                            ),
                          );
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

  Widget _imageRestaurant(Restaurant restaurant) {
    String img = restaurant.image;

    if (img == null) {
      return Image.asset(
        'images/pizza.jpg',
        fit: BoxFit.cover,
      );
    } else {
      return Image.memory(
        Base64Decoder().convert(img),
        fit: BoxFit.cover,
      );
    }
  }
}
