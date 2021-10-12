import 'package:flutter/material.dart';

// ignore: public_member_api_docs
class LightTheme {
  // ignore: public_member_api_docs
  static final theme = ThemeData(
    colorScheme: const ColorScheme.light(
      primary: Colors.yellow,
      secondary: Colors.yellow,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
    ),
    buttonTheme: const ButtonThemeData(
      colorScheme: ColorScheme(
        primary: Colors.green,
        primaryVariant: Colors.green,
        secondary: Colors.green,
        secondaryVariant: Colors.green,
        surface: Colors.green,
        background: Colors.white,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.green,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
    ),
    primaryColor: Colors.yellow,
    cardColor: Colors.white,
    backgroundColor: Colors.white,
    primaryTextTheme: TextTheme(
      bodyText2: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      button: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      headline6: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      subtitle1: TextStyle(
        fontSize: 16,
        color: Colors.grey[600],
        fontWeight: FontWeight.w100,
      ),
      subtitle2: const TextStyle(
        color: Colors.grey,
        fontSize: 16,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      unselectedItemColor: Colors.black,
      selectedItemColor: Colors.yellow,
      selectedLabelStyle: TextStyle(color: Colors.yellow),
      unselectedLabelStyle: TextStyle(color: Colors.black),
      showSelectedLabels: true,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        primary: Colors.green,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        primary: Colors.green,
        onPrimary: Colors.white,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 5,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        onSurface: Colors.green,
      ),
    ),
  );
}
