import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    background: Color.fromRGBO(0, 8, 15, 1),
    primary: Color.fromRGBO(20, 20, 19, 1),
    secondary: Colors.white,
    tertiary: Color.fromRGBO(0, 7, 12, 1),
  )
);