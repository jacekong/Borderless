import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType { light, dark }

class ThemeProvider extends ChangeNotifier {
  ThemeType _themeType = ThemeType.light;

  ThemeType get themeType => _themeType;

  ThemeProvider() {
    _loadThemeFromPreferences();
  }

  void toggleTheme() async {
    _themeType = _themeType == ThemeType.light ? ThemeType.dark : ThemeType.light;
    notifyListeners();
    await _saveThemeToPreferences();
  }

  Future<void> _loadThemeFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? themeIndex = prefs.getInt('themeType');
    if (themeIndex != null) {
      _themeType = ThemeType.values[themeIndex];
      notifyListeners();
    }
  }

  Future<void> _saveThemeToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeType', _themeType.index);
  }
}
