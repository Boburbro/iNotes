import 'package:flutter/material.dart';

class AppTheme {
  static final light = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(titleMedium: TextStyle(color: Colors.black)),
  );

  static final black = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    textTheme: const TextTheme(titleMedium: TextStyle(color: Colors.white)),
  );
}
