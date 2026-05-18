// lib/screens/login.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:klemat/helper.dart';
import 'package:klemat/screens/main_menu.dart';
import 'package:klemat/themes/app_localization.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? errorMessage;
  bool isLoading = false;
  int selectedTab = 1;

  Future<void> signIn() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final user = FirebaseAuth.instance.currentUser!;
      final displayName = user.email?.split('@').first ?? 'User';
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainMenu(username: displayName)),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> signUp() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final user = FirebaseAuth.instance.currentUser!;
      String username = user.email!.split('@').first;
      if (username.length > 12) username = username.substring(0, 12);
      await UserDataService().initializeUser(username: username);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainMenu(username: username)),
      );
      // show how-to-play on sign up:
      showHowToPlayDialog(context);
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> continueAsGuest() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final result = await FirebaseAuth.instance.signInAnonymously();
      final user = result.user!;
      final guestName = 'Guest-${user.uid.substring(0, 5)}';
      await UserDataService().initializeUser(username: guestName);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainMenu(username: guestName)),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _forgotPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate('please_enter_email'),
          ),
        ),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate('password_reset_sent'),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? AppLocalizations.of(context).translate('error_occurred'),
          ),
        ),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  return Scaffold(
    resizeToAvoidBottomInset: false,
    backgroundColor: colorScheme.surface,
    body: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus(); // ← dismiss keyboard
      },
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/Mountains.png', height: 200),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.background,
                border: Border.all(color: colorScheme.primary, width: 1.5),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Toggle between Log In / Sign Up
                  SegmentedButton<int>(
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.resolveWith((states) =>
                              states.contains(MaterialState.selected)
                                  ? Colors.white
                                  : colorScheme.tertiary),
                      backgroundColor:
                          MaterialStateProperty.resolveWith((states) =>
                              states.contains(MaterialState.selected)
                                  ? colorScheme.primary
                                  : colorScheme.surface),
                    ),
                    segments: <ButtonSegment<int>>[
                      ButtonSegment(
                        value: 1,
                        label: Text(AppLocalizations.of(context).translate('log_in')),
                      ),
                      ButtonSegment(
                        value: 2,
                        label: Text(AppLocalizations.of(context).translate('sign_up')),
                      ),
                    ],
                    selected: <int>{selectedTab},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        selectedTab = newSelection.first;
                        errorMessage = null;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Email
                  TextField(
                    controller: emailController,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate('email'),
                      labelStyle: TextStyle(color: colorScheme.onSurface),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Password
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate('password'),
                      labelStyle: TextStyle(color: colorScheme.onSurface),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit button
                  isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: selectedTab == 1 ? signIn : signUp,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              selectedTab == 1
                                  ? AppLocalizations.of(context).translate('log_in')
                                  : AppLocalizations.of(context).translate('sign_up'),
                              style: TextStyle(color: colorScheme.onSurface),
                            ),
                          ),
                        ),
                  const SizedBox(height: 10),

                  // Continue as guest
                  TextButton(
                    onPressed: continueAsGuest,
                    child: Text(
                      AppLocalizations.of(context).translate('cont_guest'),
                      style: TextStyle(color: colorScheme.secondary),
                    ),
                  ),

                  // Forgot password
                  TextButton(
                    onPressed: _forgotPassword,
                    child: Text(
                      AppLocalizations.of(context).translate('forgot_pass'),
                      style: TextStyle(color: colorScheme.tertiary),
                    ),
                  ),

                  // Error message
                  if (errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorMessage!,
                      style: TextStyle(color: colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}
