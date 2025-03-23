import 'package:borderless/provider/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguageSelection extends StatelessWidget {
  const LanguageSelection({super.key});

  static const Map<String, String> languageMap = {
    'English 🇺🇸': 'en',
    'Tiếng Việt 🇻🇳': 'vi',
    '简体中文 - 中国 🇨🇳': 'zh_CN',
    '繁體中文 - 臺灣 🇹🇼': 'zh_TW',
  };

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale.toString();

    final currentLanguage = languageMap.entries
        .firstWhere((entry) => entry.value == currentLocale, orElse: () => languageMap.entries.first)
        .key;

    return DropdownButton<String>(
      value: currentLanguage,
      onChanged: (String? selectedLanguage) {
        if (selectedLanguage != null) {
          localeProvider.setLocaleByLanguageCode(languageMap[selectedLanguage]!);
        }
      },
      items: languageMap.keys.map<DropdownMenuItem<String>>((String language) {
        return DropdownMenuItem<String>(
          value: language,
          child: Text(language),
        );
      }).toList(),
    );
  }
}
