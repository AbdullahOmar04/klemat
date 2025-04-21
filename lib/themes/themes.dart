import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade100,
    primary: Colors.grey.shade400,
    secondary: Colors.grey.shade600,
    error: Colors.red.shade600,
    onPrimary: Colors.green.shade300,
    onSecondary: Colors.orange.shade300,
    onError: Colors.grey.shade600,
    onSurface: Colors.black,
    tertiary: Colors.grey.shade800
  ),
);

final ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: Colors.grey.shade600,
    secondary: Colors.grey.shade600,
    error: const Color.fromARGB(255, 116, 8, 0),
    onPrimary: Colors.green.shade800,
    onSecondary: Colors.orange.shade700,
    onError: Colors.grey.shade800,
    onSurface: Colors.grey.shade200,
    tertiary: Colors.grey.shade400
  ),
);
