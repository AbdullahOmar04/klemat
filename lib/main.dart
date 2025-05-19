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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('ar');

  void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    final usernamelong = email?.split('@').first ?? 'Guest';
    var username = usernamelong;
    if (usernamelong.length > 12) {
      final usernameshort = usernamelong.split('').getRange(0, 13).join();
      username = usernameshort;
    }

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
          home:
              user != null
                  ? MainMenu(username: username)
                  : const LoginPage(),
        );
      },
    );
  }
}
