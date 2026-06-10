// lib/screens/login.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:klemat/helper.dart';
import 'package:klemat/screens/main_menu.dart';
import 'package:klemat/themes/app_localization.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Web OAuth client ID (type 3) from android/app/google-services.json. Required
/// so the Google ID token is minted for Firebase, not just the Android client.
const String _googleServerClientId =
    '651818657583-rv4uhrfppstevmcdl7d7vhb40iosrt7n.apps.googleusercontent.com';

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
  bool _obscurePassword = true;
  bool _isSignUp = false;
  bool _googleInitialized = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String _t(String key) => AppLocalizations.of(context).translate(key);

  // ─── Auth actions ─────────────────────────────────────────────────────────

  Future<void> signIn() async {
    if (!_validateInputs()) return;
    await _runAuth(() async {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      final user = FirebaseAuth.instance.currentUser!;
      final username = _clampName(user.email?.split('@').first ?? 'Player');
      _goToMainMenu(username);
    });
  }

  Future<void> signUp() async {
    if (!_validateInputs()) return;
    await _runAuth(() async {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      final user = FirebaseAuth.instance.currentUser!;
      final username = _clampName(user.email!.split('@').first);
      await UserDataService().initializeUser(username: username);
      _goToMainMenu(username, showHowToPlay: true);
    });
  }

  Future<void> continueAsGuest() async {
    await _runAuth(() async {
      final result = await FirebaseAuth.instance.signInAnonymously();
      final guestName = 'Guest-${result.user!.uid.substring(0, 5)}';
      await UserDataService().initializeUser(username: guestName);
      _goToMainMenu(guestName);
    });
  }

  Future<void> continueWithGoogle() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      // Native Google flow (account picker). Avoids the web-redirect
      // "missing initial state" error that signInWithProvider hit on Android.
      if (!_googleInitialized) {
        await GoogleSignIn.instance.initialize(
          serverClientId: _googleServerClientId,
        );
        _googleInitialized = true;
      }
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        if (mounted) setState(() => errorMessage = _t('google_signin_failed'));
        return;
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCred = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCred.user!;
      final isNew = userCred.additionalUserInfo?.isNewUser ?? false;
      final username = _clampName(
        user.displayName ?? user.email?.split('@').first ?? 'Player',
      );
      // initializeUser only writes if the doc doesn't exist, so this is safe
      // for returning users too.
      await UserDataService().initializeUser(username: username);
      _goToMainMenu(username, showHowToPlay: isNew);
    } on GoogleSignInException catch (e) {
      // The user simply dismissing the picker isn't an error worth showing.
      if (e.code != GoogleSignInExceptionCode.canceled && mounted) {
        setState(() => errorMessage = _t('google_signin_failed'));
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => errorMessage = _friendlyError(e));
    } catch (_) {
      if (mounted) setState(() => errorMessage = _t('google_signin_failed'));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _forgotPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showSnack(_t('please_enter_email'));
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      _showSnack(_t('password_reset_sent'));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showSnack(_friendlyError(e));
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Wraps an auth call with shared loading + error handling so each action
  /// doesn't repeat the same boilerplate.
  Future<void> _runAuth(
    Future<void> Function() action, {
    String genericErrorKey = 'error_occurred',
  }) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => errorMessage = _friendlyError(e));
    } catch (_) {
      if (mounted) setState(() => errorMessage = _t(genericErrorKey));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  bool _validateInputs() {
    final email = emailController.text.trim();
    final pass = passwordController.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => errorMessage = _t('enter_email_password'));
      return false;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() => errorMessage = _t('invalid_email'));
      return false;
    }
    if (pass.length < 6) {
      setState(() => errorMessage = _t('weak_password'));
      return false;
    }
    return true;
  }

  String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return _t('invalid_credentials');
      case 'email-already-in-use':
        return _t('email_in_use');
      case 'weak-password':
        return _t('weak_password');
      case 'invalid-email':
        return _t('invalid_email');
      case 'network-request-failed':
        return _t('network_error');
      default:
        return e.message ?? _t('error_occurred');
    }
  }

  String _clampName(String name) =>
      name.length > 12 ? name.substring(0, 12) : name;

  void _goToMainMenu(String username, {bool showHowToPlay = false}) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => MainMenu(username: username, showHowToPlay: showHowToPlay),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ─── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Branding ──
                    Image.asset('assets/images/Mountains.png', height: 120),
                    const SizedBox(height: 4),
                    Text(
                      _t('auth_subtitle'),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Login / Sign up toggle ──
                    _buildModeToggle(colorScheme),
                    const SizedBox(height: 24),

                    // ── Email ──
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: _fieldDecoration(
                        colorScheme,
                        label: _t('email'),
                        icon: Icons.email_outlined,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Password ──
                    TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _isSignUp ? signUp() : signIn(),
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: _fieldDecoration(
                        colorScheme,
                        label: _t('password'),
                        icon: Icons.lock_outline,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          onPressed:
                              () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                        ),
                      ),
                    ),

                    // ── Forgot password (login mode only) ──
                    if (!_isSignUp)
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: isLoading ? null : _forgotPassword,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            _t('forgot_pass'),
                            style: TextStyle(color: colorScheme.tertiary),
                          ),
                        ),
                      ),

                    // ── Error message ──
                    if (errorMessage != null) _buildErrorBox(colorScheme),

                    const SizedBox(height: 20),

                    // ── Primary action ──
                    _buildPrimaryButton(colorScheme),
                    const SizedBox(height: 20),

                    // ── Divider ──
                    _buildOrDivider(colorScheme),
                    const SizedBox(height: 20),

                    // ── Continue with Google ──
                    _buildGoogleButton(colorScheme),
                    const SizedBox(height: 10),

                    // ── Continue as guest ──
                    TextButton(
                      onPressed: isLoading ? null : continueAsGuest,
                      child: Text(
                        _t('cont_guest'),
                        style: TextStyle(color: colorScheme.secondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeToggle(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _toggleSegment(colorScheme, label: _t('log_in'), signUp: false),
          _toggleSegment(colorScheme, label: _t('sign_up'), signUp: true),
        ],
      ),
    );
  }

  Widget _toggleSegment(
    ColorScheme colorScheme, {
    required String label,
    required bool signUp,
  }) {
    final selected = _isSignUp == signUp;
    return Expanded(
      child: GestureDetector(
        onTap:
            () => setState(() {
              _isSignUp = signUp;
              errorMessage = null;
            }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color:
                  selected
                      ? Colors.white
                      : colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(
    ColorScheme colorScheme, {
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      prefixIcon: Icon(
        icon,
        color: colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: colorScheme.onSurface.withValues(alpha: 0.04),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.onSurface.withValues(alpha: 0.15),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
    );
  }

  Widget _buildErrorBox(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage!,
              style: TextStyle(color: colorScheme.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : (_isSignUp ? signUp : signIn),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.5),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            isLoading
                ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                : Text(
                  _isSignUp ? _t('sign_up') : _t('log_in'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }

  Widget _buildOrDivider(ColorScheme colorScheme) {
    final line = Expanded(
      child: Divider(color: colorScheme.onSurface.withValues(alpha: 0.15)),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            _t('or_divider'),
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        line,
      ],
    );
  }

  Widget _buildGoogleButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : continueWithGoogle,
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const _GoogleG(),
        label: Text(
          _t('continue_google'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// The Google "G" mark used on the sign-in button.
class _GoogleG extends StatelessWidget {
  const _GoogleG();

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/google_g.jpg', width: 20, height: 20);
  }
}
