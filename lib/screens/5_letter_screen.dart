// ignore_for_file: sort_child_properties_last, unused_field, no_leading_underscores_for_local_identifiers, unused_local_variable, constant_pattern_never_matches_value_type
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:klemat/helper.dart';
import 'package:klemat/keyboard.dart';
import 'package:klemat/themes/app_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class FiveLetterScreen extends StatefulWidget {
  final String correctWord;

  const FiveLetterScreen({super.key, required this.correctWord});

  @override
  State<StatefulWidget> createState() {
    return _FiveLetterScreen();
  }
}

class _FiveLetterScreen extends State<FiveLetterScreen>
    with TickerProviderStateMixin {
  late GameTimer _gameTimer;

  bool gameWon = false;

  int _currentTextfield = 0;

  int _fiveLettersStop = 0;

  late String _correctWord;

  int _currentRow = 0;

  int _diamonds = 0;

  int _hintsUsed = 0;

  final _userData = UserDataService();

  final List<TextEditingController> _controllers = List.generate(
    35,
    (index) => TextEditingController(),
  );

  List<Color> _fillColors = List.generate(35, (index) => Colors.transparent);

  final List<String> _colorTypes = List.generate(35, (index) => "surface");

  final List<String?> _hintLetters = List.filled(35, null);
  List<String> words = [];
  List<String> c_words = [];
  List<int> revealedIndices = [];
  final bool _readOnly = true;
  Map<String, Color> keyColors = {};

  final List<AnimationController> _shakeControllers = [];
  final List<Animation<double>> _shakeAnimations = [];

  final List<AnimationController> _scaleControllers = [];
  final List<Animation<double>> _scaleAnimations = [];

  @override
  void initState() {
    super.initState();
    _loadWordsFromJson();
    _loadUserData();
    _correctWord = widget.correctWord;

    for (int i = 0; i < 7; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );

      final animation = Tween<double>(
        begin: 0,
        end: 10,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticIn));

      _shakeControllers.add(controller);
      _shakeAnimations.add(animation);
    }

    for (int i = 0; i < 35; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );

      final animation = Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        }
      });

      _scaleControllers.add(controller);
      _scaleAnimations.add(animation);
    }

    _gameTimer = GameTimer(
      onTick: () {
        setState(() {});
      },
    );
    _gameTimer.start();
  }

  void _shakeCurrentRow() {
    _shakeControllers[_currentRow].forward(from: 0);
  }

  Future<void> _vibrateTwice() async {
    final prefs = await SharedPreferences.getInstance();
    bool isHapticEnabled = prefs.getBool('isHapticEnabled') ?? true;

    if (!isHapticEnabled) return; // Skip if haptic feedback is disabled

    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.lightImpact();
  }

  void _triggerPopUp(int index) {
    if (index >= 0 && index < _scaleControllers.length) {
      _scaleControllers[index].forward();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateFillColors();
    _updateKeyColors();
  }

  Future<void> _loadUserData() async {
    final amount = await _userData.loadDiamonds();
    setState(() {
      _diamonds = amount;
    });
  }

  Future<void> _loadWordsFromJson() async {
    final jsonString = await rootBundle.loadString(
      'assets/words/5_letters/5_letter_words_all.json',
    );
    final jsonString2 = await rootBundle.loadString(
      'assets/words/5_letters/5_letter_answers.json',
    );

    final wordsList = await parseWords(jsonString, 'words');
    final cWordsList = await parseWords(jsonString2, 'c_words');

    setState(() {
      words = wordsList;
      c_words = cWordsList;
    });

    //_getRandomWord(c_words);
  }

  /*
  void _getRandomWord(List<String> woords) {
    final random = Random();
    setState(() {
      _correctWord = c_words[random.nextInt(woords.length)];
    });
  }
*/

  @override
  void dispose() {
    for (var controller in _shakeControllers) {
      controller.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var controller in _scaleControllers) {
      controller.dispose();
    }
    _gameTimer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.all(5),
          width: 85,
          decoration: BoxDecoration(
            color: const Color.fromARGB(94, 131, 131, 131),
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              width: 1.5,
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer, size: 25),
              const SizedBox(width: 5),
              Text(_gameTimer.formattedTime, style: TextStyle(fontSize: 15)),
            ],
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            onPressed: () {
              showStatsDialog(context);
            },
            icon: Icon(Icons.analytics),
          ),
          GestureDetector(
            child: coins(context, _diamonds),
            onTap: () {
              openShop(context);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          for (int i = 0; i < 7; i++)
            AnimatedBuilder(
              animation: _shakeAnimations[i],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    _shakeAnimations[i].value *
                        sin(_shakeControllers[i].value * 2 * pi),
                    0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int j = 4; j >= 0; j--)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 3.0,
                            vertical: 3,
                          ),
                          child: SizedBox(
                            height: 60,
                            width: 60,
                            child: AnimatedBuilder(
                              animation: _scaleAnimations[i * 5 + j],
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimations[i * 5 + j].value,
                                  child: child,
                                );
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (_controllers[i * 5 + j].text.isEmpty &&
                                      _hintLetters[i * 5 + j] != null)
                                    Text(
                                      _hintLetters[i * 5 + j]!,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Colors
                                                .grey, // or use Color with some opacity, e.g., Colors.grey.withOpacity(0.5)
                                      ),
                                    ),
                                  TextField(
                                    controller: _controllers[i * 5 + j],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    readOnly: _readOnly,
                                    textAlign: TextAlign.center,
                                    maxLength: 1,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(1),
                                    ],
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                        ),
                                      ),
                                      fillColor: _fillColors[i * 5 + j],
                                      filled: true,
                                      counterText: '',
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

          CustomKeyboard(
            onTextInput: (myText) => _insertText(myText),
            onBackspace: _backspace,
            onSubmit: _submit,
            keyColors: keyColors,
            onRevealHint: _revealHint,
          ),
        ],
      ),
    );
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  void _revealHint() async {
    if (_diamonds < 15) {
      _vibrateTwice();
      _shakeCurrentRow();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          dismissDirection: DismissDirection.horizontal,
          duration: const Duration(seconds: 2),
          content: Text(
            AppLocalizations.of(context).translate('not_enough_diamonds'),
            style: TextStyle(color: Colors.grey.shade200, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            right: 20,
            left: 20,
          ),
        ),
      );
      return;
    }

    int startIndex = _currentRow * 5;
    int endIndex = startIndex + 4;

    Set<String> guessed =
        _controllers
            .map((c) => c.text.trim())
            .where((c) => c.isNotEmpty)
            .toSet();

    List<int> availableIndices = [];

    for (int i = startIndex; i <= endIndex; i++) {
      final letter = _correctWord[i % 5];
      if (!revealedIndices.contains(i) && !guessed.contains(letter)) {
        availableIndices.add(i);
      }
    }

    if (!gameWon && availableIndices.isNotEmpty) {
      int randomIndex =
          availableIndices[Random().nextInt(availableIndices.length)];
      String letter = _correctWord[randomIndex % 5];
      if (!mounted) return;
      setState(() {
        _hintLetters[randomIndex] = letter;
        _fillColors[randomIndex] = const Color.fromARGB(122, 158, 158, 158);
        revealedIndices.add(randomIndex);
        _hintsUsed++;
        _diamonds -= 15;
      });

      unawaited(UserDataService().spendDiamonds(15));
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  void _updateFillColors() {
    final newFillColors = List<Color>.from(_fillColors); // Copy current list
    final colorScheme = Theme.of(context).colorScheme;

    for (int i = 0; i < newFillColors.length; i++) {
      switch (_colorTypes[i]) {
        case "onPrimary":
          newFillColors[i] = colorScheme.onPrimary;
          break;
        case "onSecondary":
          newFillColors[i] = colorScheme.onSecondary;
          break;
        case "onError":
          newFillColors[i] = colorScheme.onError;
          break;
        default:
          newFillColors[i] = Colors.transparent;
      }
    }

    setState(() {
      _fillColors = newFillColors;
    });
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  void _updateKeyColors() {
    final newKeyColors = <String, Color>{};
    final colorScheme = Theme.of(context).colorScheme;

    for (int i = 0; i < _currentTextfield; i++) {
      String letter = _controllers[i].text;
      if (letter.isEmpty) continue;

      Color keyColor;
      switch (_colorTypes[i]) {
        case "onPrimary":
          keyColor = colorScheme.onPrimary;
          break;
        case "onSecondary":
          keyColor = colorScheme.onSecondary;
          break;
        case "onError":
          keyColor = colorScheme.onError;
          break;
        default:
          keyColor = colorScheme.primary;
      }
      newKeyColors[letter] = keyColor;
    }

    setState(() {
      keyColors = newKeyColors;
    });
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  void _insertText(String myText) {
    if ((_currentTextfield < 35 && _fiveLettersStop < 5) && gameWon == false) {
      final controller = _controllers[_currentTextfield];

      controller.text = myText;

      setState(() {
        _triggerPopUp(_currentTextfield);
        _currentTextfield++;
        _fiveLettersStop++;
      });
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  void _backspace() {
    if ((_currentTextfield > 0 && _fiveLettersStop > 0) && gameWon == false) {
      setState(() {
        _currentTextfield--;
        _fiveLettersStop--;
      });

      _controllers[_currentTextfield].clear();
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  void _submit() async {
    print(_correctWord);

    // 1) Check that we have exactly 5 letters in the current row
    if (_currentTextfield % 5 != 0 || _fiveLettersStop != 5) {
      _vibrateTwice();
      _shakeCurrentRow();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          dismissDirection: DismissDirection.horizontal,
          duration: const Duration(seconds: 2),
          content: Text(
            AppLocalizations.of(context).translate('five_letter_error'),
            style: TextStyle(color: Colors.grey.shade200, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            right: 20,
            left: 20,
          ),
        ),
      );
      return;
    }

    // 2) Build the guessed word from the last 5 textfields
    List<String> _currentWordList = [];
    String _currentWord = "";
    String _guessedLetter;

    int startIndex = _currentTextfield - 5;
    int endIndex = _currentTextfield - 1;

    // Decompose the correct word into letters and count frequencies
    List<String> _deconstructedCorrectWord = _correctWord.split('');
    Map<String, int> letterCounts = {};
    for (var letter in _deconstructedCorrectWord) {
      letterCounts[letter] = (letterCounts[letter] ?? 0) + 1;
    }

    // Gather the letters the user has typed in this row
    for (int i = startIndex; i <= endIndex; i++) {
      _currentWordList.add(_controllers[i].text);
    }
    _currentWord = _currentWordList.join("");

    // 3) If the guessed word is not in your valid‐words list, show shake+snackbar
    if (!words.contains(_currentWord)) {
      _vibrateTwice();
      _shakeCurrentRow();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          dismissDirection: DismissDirection.horizontal,
          duration: const Duration(seconds: 2),
          content: Text(
            AppLocalizations.of(context).translate('not_in_library'),
            style: TextStyle(color: Colors.grey.shade200, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            right: 20,
            left: 20,
          ),
        ),
      );
      return;
    }

    // 4) If the guess matches the correct word, handle the “win” logic
    if (_currentWord == _correctWord) {
      // Color all letters in this row green (onPrimary)
      for (int k = startIndex; k <= endIndex; k++) {
        _guessedLetter = _controllers[k].text;
        _fillColors[k] = Theme.of(context).colorScheme.onPrimary;
        keyColors[_guessedLetter] = Theme.of(context).colorScheme.onPrimary;
        _colorTypes[k] = "onPrimary";
      }

      // Stop the timer and mark game as won
      setState(() {
        gameWon = true;
        _gameTimer.stop();
      });

      // 4a) Increment winStreak. If it just reached 3, award 50 diamonds
      if (winStreak < 3) {
        winStreak++;
        if (winStreak == 3) {
          await UserDataService().awardDiamonds(50);
        }
      }

      // 4b) If solved in under 120 seconds and timeWinStreak == 0, award 30 diamonds
      if (_gameTimer.elapsedSeconds < 120 && timeWinStreak == 0) {
        setState(() {
          timeWinStreak++;
        });
        await UserDataService().awardDiamonds(30);
      }

      // 4c) Record the win in Firestore & in‐memory stats
      //     Use (_currentRow + 1) as the “guess count” for distribution.
      await UserDataService().recordGame(
        won: true,
        guesses: _currentRow + 1, // row index starts at 0
      );

      // 4d) Show definition popup
      showDefinitionDialog(context, _correctWord);

      // 4e) Advance their “currentFiveModeLevel” in Firestore
      currentFiveModeLevel++;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({'currentLevel5': currentFiveModeLevel});

      // 4f) Award “points” based on row/hints, and update Firestore
      points = calculatePoints("Mode 5", _currentRow, _hintsUsed);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .set({
            'points': FieldValue.increment(points),
            'username':
                FirebaseAuth.instance.currentUser?.email?.split('@').first ??
                'Guest',
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } else {
      // 5) “Color‐hint” logic for an incorrect guess (letters in correct spot, etc.)
      //    First pass: mark exact matches green
      for (int i = startIndex, j = 0; i <= endIndex; i++, j++) {
        _guessedLetter = _controllers[i].text;
        if (_guessedLetter == _deconstructedCorrectWord[j]) {
          _fillColors[i] = Theme.of(context).colorScheme.onPrimary;
          keyColors[_guessedLetter] = Theme.of(context).colorScheme.onPrimary;
          _colorTypes[i] = "onPrimary";
          // reduce count so we don't over‐count duplicates
          letterCounts[_guessedLetter] = letterCounts[_guessedLetter]! - 1;
        }
      }

      // 5b) Second pass: mark “in word but wrong spot” (onSecondary), else gray (onError)
      for (int i = startIndex, j = 0; i <= endIndex; i++, j++) {
        _guessedLetter = _controllers[i].text;
        if (_fillColors[i] != Theme.of(context).colorScheme.onPrimary) {
          if (letterCounts[_guessedLetter] != null &&
              letterCounts[_guessedLetter]! > 0) {
            _fillColors[i] = Theme.of(context).colorScheme.onSecondary;
            _colorTypes[i] = "onSecondary";
            if (keyColors[_guessedLetter] !=
                Theme.of(context).colorScheme.onPrimary) {
              keyColors[_guessedLetter] =
                  Theme.of(context).colorScheme.onSecondary;
            }
            letterCounts[_guessedLetter] = letterCounts[_guessedLetter]! - 1;
          } else {
            _fillColors[i] = Theme.of(context).colorScheme.onError;
            _colorTypes[i] = "onError";
            if (keyColors[_guessedLetter] !=
                    Theme.of(context).colorScheme.onPrimary &&
                keyColors[_guessedLetter] !=
                    Theme.of(context).colorScheme.onSecondary) {
              keyColors[_guessedLetter] = Theme.of(context).colorScheme.onError;
            }
          }
        }
      }

      // 5c) If this was the last possible guess (i.e. 35 letters ≡ 7 rows of 5)
      if (_currentTextfield == 35 && gameWon == false) {
        // Reset the winStreak to zero on a loss
        winStreak = 0; // ← FIX: reset streak immediately

        // Record the loss in stats (played +1, wins unchanged, currentStreak→0, distribution)
        // Here we pass guesses = (_currentRow + 1). Even though it's a loss, we
        // want to increment “played,” reset streak, etc.
        await UserDataService().recordGame(won: false);

        // Make sure Firestore & local streak fields are in sync
        await UserDataService().saveStreaks(
          winStreak: winStreak,
          dailyWinStreak: dailyWinStreak,
          timeWinStreak: timeWinStreak,
          points: points,
        );

        // Show a “You lost” dialog with the correct word
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.surface,
                title: Text(
                  AppLocalizations.of(context).translate('incorrect'),
                  textAlign: TextAlign.center,
                ),
                content: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(
                          context,
                        ).translate('correct_word'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: _correctWord,
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.blue.shade300,
                        ),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () {
                                launchUrl(
                                  Uri.parse(
                                    'https://www.almaany.com/ar/dict/ar-ar/$_correctWord/?',
                                  ),
                                );
                              },
                      ),
                      TextSpan(
                        text: AppLocalizations.of(
                          context,
                        ).translate('how_to_pronounce'),
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.blue.shade300,
                        ),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () {
                                launchUrl(
                                  Uri.parse(
                                    'https://forvo.com/word/$_correctWord',
                                  ),
                                );
                              },
                      ),
                    ],
                  ),
                ),
              ),
        );
      }
    }

    // 6) Clear out the word buffer and move to the next row
    _currentWordList.clear();
    _fiveLettersStop = 0;
    _currentRow++;

    // 7) Record that this word was “gotten” (so you don’t repeat it, etc.)
    await UserDataService().addGottenWord(_correctWord);

    // 8) Finally, save all streaks/points one more time, in case anything changed
    //    (In the “win” branch, we already called recordGame(...) which updated GameStatsSnapshot.
    //     In the “loss” branch, we called recordGame(...) and saveStreaks(...) as well.)
    await UserDataService().saveStreaks(
      winStreak: winStreak,
      dailyWinStreak: dailyWinStreak,
      timeWinStreak: timeWinStreak,
      points: points,
    );
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
