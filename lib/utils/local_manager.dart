import 'package:flutter/material.dart';

class LocaleManager {
  static const supportedLocales = [
    Locale('en', ''), 
    Locale('zh', 'CN'),
    Locale('zh', 'TW'),
    Locale('vi', ''),
  ];

  static const defaultLocale = Locale('en', '');

  static Locale findLocale(String languageCode, String? countryCode) {
    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == languageCode &&
          (countryCode == null || locale.countryCode == countryCode),
      orElse: () => defaultLocale,
    );
  }
}