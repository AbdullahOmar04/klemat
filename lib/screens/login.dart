import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:klemat/helper.dart';
import 'package:klemat/screens/main_menu.dart';
import 'package:klemat/themes/app_localization.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainMenu(username: emailController.text.trim()),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
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
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;
      final usernamelong = email?.split('@').first ?? 'Guest';
      var username = usernamelong;
      if (usernamelong.length > 12) {
        final usernameshort = usernamelong.split('').getRange(0, 13).join();
        username = usernameshort;
      }

      await UserDataService().initializeUser(username: username);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainMenu(username: emailController.text.trim()),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your email address.')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Password reset email sent.')));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Error occurred.')));
    }
  }

  void continueAsGuest() {
    Random guestNum = Random(1000);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainMenu(username: 'Guest-$guestNum'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.background,
                          border: Border.all(
                            color: colorScheme.primary,
                            width: 1.5,
                          ),
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
                            SegmentedButton<int>(
                              showSelectedIcon: false,
                              style: ButtonStyle(
                                foregroundColor:
                                    WidgetStateProperty.resolveWith(
                                      (states) =>
                                          states.contains(WidgetState.selected)
                                              ? Colors.white
                                              : colorScheme.tertiary,
                                    ),
                                backgroundColor:
                                    WidgetStateProperty.resolveWith(
                                      (states) =>
                                          states.contains(WidgetState.selected)
                                              ? colorScheme.primary
                                              : colorScheme.surface,
                                    ),
                              ),
                              segments: <ButtonSegment<int>>[
                                ButtonSegment(
                                  value: 1,
                                  label: Text(
                                    AppLocalizations.of(
                                      context,
                                    ).translate('log_in'),
                                  ),
                                ),
                                ButtonSegment(
                                  value: 2,
                                  label: Text(
                                    AppLocalizations.of(
                                      context,
                                    ).translate('sign_up'),
                                  ),
                                ),
                              ],
                              selected: <int>{selectedTab},
                              onSelectionChanged: (Set<int> newSelection) {
                                setState(() {
                                  selectedTab = newSelection.first;
                                  errorMessage = null;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: emailController,
                              style: TextStyle(color: colorScheme.onSurface),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(
                                  context,
                                ).translate('email'),
                                labelStyle: TextStyle(
                                  color: colorScheme.onSurface,
                                ),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: passwordController,
                              
                              obscureText: true,
                              style: TextStyle(color: colorScheme.onSurface),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(
                                  context,
                                ).translate('password'),
                                labelStyle: TextStyle(
                                  color: colorScheme.onSurface,
                                ),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            isLoading
                                ? const CircularProgressIndicator()
                                : SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed:
                                        selectedTab == 1 ? signIn : signUp,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      backgroundColor: colorScheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      selectedTab == 1
                                          ? AppLocalizations.of(
                                            context,
                                          ).translate('log_in')
                                          : AppLocalizations.of(
                                            context,
                                          ).translate('sign_up'),
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: continueAsGuest,
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                ).translate('cont_guest'),
                                style: TextStyle(color: colorScheme.secondary),
                              ),
                            ),
                            TextButton(
                              onPressed: _forgotPassword,
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                ).translate('forgot_pass'),
                                style: TextStyle(color: colorScheme.tertiary),
                              ),
                            ),
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
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
