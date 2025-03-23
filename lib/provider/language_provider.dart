import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('selectedLocale');
    if (savedLocale != null) {
      final parts = savedLocale.split('_');
      _locale = Locale(parts[0], parts.length > 1 ? parts[1] : null);
      notifyListeners();
    }
  }

  void setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedLocale', locale.toLanguageTag());
  }

  void setLocaleByLanguageCode(String languageCode) async {
    final parts = languageCode.split('_');
    _locale = Locale(parts[0], parts.length > 1 ? parts[1] : null);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedLocale', languageCode);
  }
}
