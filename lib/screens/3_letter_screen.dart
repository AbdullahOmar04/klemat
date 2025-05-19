// ignore_for_file: non_constant_identifier_names
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
import 'package:url_launcher/url_launcher.dart';

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

  List<String?> _hintLetters = List.filled(21, null);
  List<String> words = [];
  List<String> c_words = [];
  final bool _readOnly = true;
  List<int> revealedIndices = [];
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
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: SizedBox(
                            height: 65,
                            width: 65,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _revealHint,
                icon: const Icon(Icons.search_rounded),
                iconSize: 35,
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 10,
                ),
              ),
            ],
          ),
          CustomKeyboard(
            onTextInput: (myText) => _insertText(myText),
            onBackspace: _backspace,
            onSubmit: _submit,
            keyColors: keyColors,
          ),
        ],
      ),
    );
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  void _revealHint() {
    int startIndex = _currentRow * 3;
    int endIndex = startIndex + 2;

    // Get all guessed letters so far
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

      setState(() {
        _hintLetters[randomIndex] = letter;
        _fillColors[randomIndex] = const Color.fromARGB(122, 158, 158, 158);
        revealedIndices.add(randomIndex);
      });
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

    if (currentWord == _correctWord) {
      for (int k = startIndex; k <= endIndex; k++) {
        guessedLetter = _controllers[k].text;
        _fillColors[k] = Theme.of(context).colorScheme.onPrimary;
        keyColors[guessedLetter] = Theme.of(context).colorScheme.onPrimary;
        _colorTypes[k] = "onPrimary";
      }

      setState(() {
        gameWon = true;
        _gameTimer.stop();
      });

      if (winStreak < 3) {
        winStreak++;
        if (winStreak == 3) {
          await UserDataService().awardDiamonds(50);
        }
      } else {
        winStreak++;
      }

      if (_gameTimer.elapsedSeconds < 120 && timeWinStreak == 0) {
        timeWinStreak++;
        await UserDataService().awardDiamonds(30);
      }

      await UserDataService().recordGame(won: true, guesses: _currentRow + 1);

      showDefinitionDialog(context, _correctWord);
      currentThreeModeLevel++;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({
            'score': FieldValue.increment(1), // or any score increment logic
          });
    } else {
      for (int i = startIndex, j = 0; i <= endIndex; i++, j++) {
        guessedLetter = _controllers[i].text;

        if (guessedLetter == deconstructedCorrectWord[j]) {
          _fillColors[i] = Theme.of(context).colorScheme.onPrimary;
          keyColors[guessedLetter] = Theme.of(context).colorScheme.onPrimary;
          _colorTypes[i] = "onPrimary";
          letterCounts[guessedLetter] = letterCounts[guessedLetter]! - 1;
        }
      }

      for (int i = startIndex, j = 0; i <= endIndex; i++, j++) {
        guessedLetter = _controllers[i].text;

        if (_fillColors[i] != Theme.of(context).colorScheme.onPrimary) {
          if (letterCounts.containsKey(guessedLetter) &&
              letterCounts[guessedLetter]! > 0) {
            _fillColors[i] = Theme.of(context).colorScheme.onSecondary;
            _colorTypes[i] = "onSecondary";
            letterCounts[guessedLetter] = letterCounts[guessedLetter]! - 1;

            if (keyColors[guessedLetter] !=
                Theme.of(context).colorScheme.onPrimary) {
              keyColors[guessedLetter] =
                  Theme.of(context).colorScheme.onSecondary;
            }
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

      if (_currentTextfield == 21 && !gameWon) {
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
                    ],
                  ),
                ),
              ),
        );
      }
    }

    currentWordList.clear();
    _fiveLettersStop = 0;
    _currentRow++;

    await UserDataService().addGottenWord(_correctWord);
    await UserDataService().saveStreaks(
      winStreak: winStreak,
      dailyWinStreak: dailyWinStreak,
      timeWinStreak: timeWinStreak,
    );
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
