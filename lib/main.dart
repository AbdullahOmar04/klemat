import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:klemat/screens/login.dart';
import 'package:klemat/screens/main_menu.dart';
import 'package:provider/provider.dart';
import 'package:klemat/themes/theme_provider.dart';
import 'package:klemat/themes/themes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:klemat/themes/app_localization.dart';
import 'package:klemat/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final langCode = prefs.getString('languageCode') ?? 'ar';
  final themeModeStr = prefs.getString('themeMode') ?? 'system';

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(initialMode: _parseThemeMode(themeModeStr)),
      child: MyApp(locale: Locale(langCode)),
    ),
  );
}

ThemeMode _parseThemeMode(String mode) {
  switch (mode) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

class MyApp extends StatefulWidget {
  final Locale locale;
  const MyApp({super.key, required this.locale});

  @override
  _MyAppState createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.locale;
  }

  void changeLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);

    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    final usernamelong = email?.split('@').first ?? 'Guest';
    final username =
        usernamelong.length > 12 ? usernamelong.substring(0, 13) : usernamelong;

    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          navigatorObservers: [routeObserver],
          debugShowCheckedModeBanner: false,
          locale: _locale,
          builder:
              (context, child) => Directionality(
                textDirection: TextDirection.ltr,
                child: child!,
              ),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeNotifier.themeMode,
          home: user != null ? MainMenu(username: username) : const LoginPage(),
        );
      },
    );
  }
}
