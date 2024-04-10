import 'package:flutter/material.dart';

enum ThemeType { light, dark }

class ThemeProvider extends ChangeNotifier {
  ThemeType _themeType = ThemeType.light;

  ThemeType get themeType => _themeType;

  void toggleTheme() {
    _themeType = _themeType == ThemeType.light ? ThemeType.dark : ThemeType.light;
    notifyListeners();
  }
}

