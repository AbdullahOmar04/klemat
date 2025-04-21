import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode;

  ThemeNotifier()
      : _themeMode =
            PlatformDispatcher.instance.platformBrightness == Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }
}
