import 'package:flutter/material.dart';

class AppTheme {
  static final light = ThemeData(
    useMaterial3: false,
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(titleMedium: TextStyle(color: Colors.black)),
  );

  static final black = ThemeData(
    useMaterial3: false,
    scaffoldBackgroundColor: Colors.black,
    textTheme: const TextTheme(titleMedium: TextStyle(color: Colors.white)),
  );
}
