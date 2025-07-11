// ignore_for_file: non_constant_identifier_names
import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:klemat/helper.dart';
import 'package:klemat/keyboard.dart';
import 'package:klemat/themes/app_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

class ThreeLetterScreen extends StatefulWidget {
  final String correctWord;

  const ThreeLetterScreen({super.key, required this.correctWord});
  @override
  State<StatefulWidget> createState() {
    return _ThreeLetterScreen();
  }
}

class _ThreeLetterScreen extends State<ThreeLetterScreen>
    with TickerProviderStateMixin {
  late GameTimer _gameTimer;

  bool gameWon = false;

  int _currentTextfield = 0;

  int _fiveLettersStop = 0;

  // ignore: unused_field
  int _hintsUsed = 0;

  late String _correctWord;

  int _currentRow = 0;
  int _diamonds = 0;
  final _userData = UserDataService();

  final List<TextEditingController> _controllers = List.generate(
    21,
    (index) => TextEditingController(),
  );

  List<Color> _fillColors = List.generate(21, (index) => Colors.transparent);

  final List<String> _colorTypes = List.generate(21, (index) => "surface");

  final List<String?> _hintLetters = List.filled(21, null);
  List<String> words = [];
  List<String> c_words = [];
  final bool _readOnly = true;
  List<int> revealedIndices = [];
  Map<String, Color> keyColors = {};

  final List<AnimationController> _shakeControllers = [];
  final List<Animation<double>> _shakeAnimations = [];

  final List<AnimationController> _scaleControllers = [];
  final List<Animation<double>> _scaleAnimations = [];

  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _loadWordsFromJson();
    _loadUserData();
    _correctWord = widget.correctWord;
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );

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

    for (int i = 0; i < 21; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );

      final animation = Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse(); // Return to normal size after popping up
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

    if (!isHapticEnabled) return;

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
    // Load the JSON strings asynchronously.
    final jsonString = await rootBundle.loadString(
      'assets/words/3_letters/3_letter_words_all.json',
    );
    final jsonString2 = await rootBundle.loadString(
      'assets/words/3_letters/3_letter_answers.json',
    );

    // Parse the JSON using compute to run in a background isolate.
    final wordsList = await parseWords(jsonString, 'words');
    final cWordsList = await parseWords(jsonString2, 'c_words');

    // Update state with the parsed word lists.
    setState(() {
      words = wordsList;
      c_words = cWordsList;
    });
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
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: Container(
          padding: EdgeInsets.all(5),
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
          GestureDetector(
            child: coins(context, _diamonds),
            onTap: () {
              openShop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Spacer(),
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
                      for (int j = 2; j >= 0; j--)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 3.0,
                            vertical: 3,
                          ),
                          child: SizedBox(
                            height: 60,
                            width: 60,
                            child: AnimatedBuilder(
                              animation: _scaleAnimations[i * 3 + j],
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimations[i * 3 + j].value,
                                  child: child,
                                );
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Show hint letter if:
                                  // - The controller's text is empty (i.e., user hasn't typed)
                                  // - And there is a hint letter set in _hintLetters list.
                                  if (_controllers[i * 3 + j].text.isEmpty &&
                                      _hintLetters[i * 3 + j] != null)
                                    Text(
                                      _hintLetters[i * 3 + j]!,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Colors
                                                .grey, // or use Color with some opacity, e.g., Colors.grey.withOpacity(0.5)
                                      ),
                                    ),
                                  TextField(
                                    controller: _controllers[i * 3 + j],
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
                                      fillColor: _fillColors[i * 3 + j],
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
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality:
                BlastDirectionality.explosive, // shoots in all directions
            shouldLoop: false, // just one burst
            emissionFrequency: 0.05, // how many particles per frame
            numberOfParticles: 20, // total particles per blast
            maxBlastForce: 20, // how far they go
            minBlastForce: 5,
            gravity: 0.2, // gravity pull
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

    int startIndex = _currentRow * 3;
    int endIndex = startIndex + 2;

    Set<String> guessed =
        _controllers
            .map((c) => c.text.trim())
            .where((c) => c.isNotEmpty)
            .toSet();

    List<int> availableIndices = [];

    for (int i = startIndex; i <= endIndex; i++) {
      final letter = _correctWord[i % 3];
      if (!revealedIndices.contains(i) && !guessed.contains(letter)) {
        availableIndices.add(i);
      }
    }

    if (!gameWon && availableIndices.isNotEmpty) {
      int randomIndex =
          availableIndices[Random().nextInt(availableIndices.length)];
      String letter = _correctWord[randomIndex % 3];

      if (!mounted) return;
      setState(() {
        _hintLetters[randomIndex] = letter;
        _fillColors[randomIndex] = const Color.fromARGB(122, 158, 158, 158);
        revealedIndices.add(randomIndex);
        _hintsUsed++;
        _diamonds -= 15;
      });

      // Firestore update in background
      unawaited(UserDataService().spendDiamonds(15));
    }
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////
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
    if ((_currentTextfield < 21 && _fiveLettersStop < 3) && gameWon == false) {
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

    // 1) Ensure exactly 3 letters are filled in the current row
    if (_currentTextfield % 3 != 0 || _fiveLettersStop != 3) {
      _vibrateTwice();
      _shakeCurrentRow();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          dismissDirection: DismissDirection.horizontal,
          duration: const Duration(seconds: 2),
          content: Text(
            AppLocalizations.of(context).translate('three_letter_error'),
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

    // 2) Build the guessed word from the last 3 textfields
    List<String> currentWordList = [];
    String currentWord = "";
    String guessedLetter;

    int startIndex = _currentTextfield - 3;
    int endIndex = _currentTextfield - 1;

    List<String> deconstructedCorrectWord = _correctWord.split('');
    Map<String, int> letterCounts = {};

    for (var letter in deconstructedCorrectWord) {
      letterCounts[letter] = (letterCounts[letter] ?? 0) + 1;
    }

    for (int i = startIndex; i <= endIndex; i++) {
      currentWordList.add(_controllers[i].text);
    }

    currentWord = currentWordList.join("");

    // 3) If guessed word is not in dictionary, shake + snackbar
    if (!words.contains(currentWord)) {
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

    // 4) If guess matches the correct word → WIN
    if (currentWord == _correctWord) {
      _confettiController.play();
      for (int k = startIndex; k <= endIndex; k++) {
        guessedLetter = _controllers[k].text;
        _fillColors[k] = Theme.of(context).colorScheme.onPrimary;
        keyColors[guessedLetter] = Theme.of(context).colorScheme.onPrimary;
        _colorTypes[k] = "onPrimary";
      }

      // 4b) Stop the timer and mark game as won
      setState(() {
        gameWon = true;
        _gameTimer.stop();
      });

      // 4c) Increment winStreak; if it just reached 3, award 50 diamonds
      if (winStreak < 3) {
        winStreak++;
        if (winStreak == 3) {
          await UserDataService().awardDiamonds(50);
        }
      }

      // 4d) If solved under 120 seconds and timeWinStreak == 0, award 30 diamonds
      if (_gameTimer.elapsedSeconds < 120 && timeWinStreak == 0) {
        setState(() {
          timeWinStreak++;
        });
        await UserDataService().awardDiamonds(30);
      }

      // 4e) Record the win in stats (won: true, guesses = _currentRow + 1)
      await UserDataService().recordGame(won: true, guesses: _currentRow + 1);

      // 4f) Show definition popup
      showDefinitionDialog(context, _correctWord);

      // 4g) Advance “currentThreeModeLevel” in Firestore
      currentThreeModeLevel++;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({'currentLevel3': currentThreeModeLevel});

      // 4h) Award points based on row/hints, then update Firestore
      final int reward = calculatePoints("Mode 3", _currentRow, _hintsUsed);
      points += reward;

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
      // 5) “Color‐hint” logic for an incorrect guess:

      // 5a) First pass: correct letters in the correct position → green
      for (int i = startIndex, j = 0; i <= endIndex; i++, j++) {
        guessedLetter = _controllers[i].text;
        if (guessedLetter == deconstructedCorrectWord[j]) {
          _fillColors[i] = Theme.of(context).colorScheme.onPrimary;
          keyColors[guessedLetter] = Theme.of(context).colorScheme.onPrimary;
          _colorTypes[i] = "onPrimary";
          letterCounts[guessedLetter] = letterCounts[guessedLetter]! - 1;
        }
      }

      // 5b) Second pass: letters in word but wrong spot → orange; else gray
      for (int i = startIndex, j = 0; i <= endIndex; i++, j++) {
        guessedLetter = _controllers[i].text;
        if (_fillColors[i] != Theme.of(context).colorScheme.onPrimary) {
          if (letterCounts[guessedLetter] != null &&
              letterCounts[guessedLetter]! > 0) {
            _fillColors[i] = Theme.of(context).colorScheme.onSecondary;
            _colorTypes[i] = "onSecondary";
            if (keyColors[guessedLetter] !=
                Theme.of(context).colorScheme.onPrimary) {
              keyColors[guessedLetter] =
                  Theme.of(context).colorScheme.onSecondary;
            }
            letterCounts[guessedLetter] = letterCounts[guessedLetter]! - 1;
          } else {
            _fillColors[i] = Theme.of(context).colorScheme.onError;
            _colorTypes[i] = "onError";
            if (keyColors[guessedLetter] !=
                    Theme.of(context).colorScheme.onPrimary &&
                keyColors[guessedLetter] !=
                    Theme.of(context).colorScheme.onSecondary) {
              keyColors[guessedLetter] = Theme.of(context).colorScheme.onError;
            }
          }
        }
      }

      // 6) If this was the last possible guess (3 letters × 7 rows = 21 textfields) → LOSS
      if (_currentTextfield == 21 && !gameWon) {
        // 6a) Reset winStreak to zero
        winStreak = 0;
        setState(() {
          gameWon = false;
          _gameTimer.stop();
        });

        // 6b) Record the loss (won: false → no distribution increment)
        await UserDataService().recordGame(won: false);

        // 6c) Save streaks so Firestore’s winStreak → 0 (daily/time/points unchanged)
        await UserDataService().saveStreaks(
          winStreak: winStreak,
          dailyWinStreak: dailyWinStreak,
          timeWinStreak: timeWinStreak,
          points: points,
        );

        // 6d) Show “You lost” dialog
        incorrectWordDialog(context);
      }
    }

    // 7) Advance to next row, mark the word as “gotten,” and save streaks/points
    currentWordList.clear();
    _fiveLettersStop = 0;
    _currentRow++;
    await UserDataService().addGottenWord(_correctWord);

    // 8) Final save of streaks/points (in case any bonus changed)
    await UserDataService().saveStreaks(
      winStreak: winStreak,
      dailyWinStreak: dailyWinStreak,
      timeWinStreak: timeWinStreak,
      points: points,
    );
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
