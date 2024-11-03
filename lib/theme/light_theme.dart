import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    primary: const Color.fromARGB(255, 242, 246, 247),
    secondary: Colors.black,
    tertiary: Colors.grey.shade200,
  )
);