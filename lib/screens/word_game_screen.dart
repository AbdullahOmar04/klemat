// ignore_for_file: non_constant_identifier_names
import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:klemat/helper.dart';
import 'package:klemat/keyboard.dart';
import 'package:klemat/themes/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

/// A single Wordle-style game screen that adapts to the given [wordLength]
/// (3, 4, or 5). It replaces the former Three/Four/FiveLetterScreen classes,
/// which were near-identical copies.
class WordGameScreen extends StatefulWidget {
  final String correctWord;
  final int wordLength;

  const WordGameScreen({
    super.key,
    required this.correctWord,
    required this.wordLength,
  });

  @override
  State<WordGameScreen> createState() => _WordGameScreenState();
}

class _WordGameScreenState extends State<WordGameScreen>
    with TickerProviderStateMixin {
  static const int _rows = 7;

  late final int _wordLength = widget.wordLength;
  late final int _totalCells = _wordLength * _rows;

  late GameTimer _gameTimer;

  bool gameWon = false;

  int _currentTextfield = 0;
  int _lettersInRow = 0;
  int _hintsUsed = 0;

  late String _correctWord;

  int _currentRow = 0;
  int _diamonds = 0;

  final _userData = UserDataService();

  late final List<TextEditingController> _controllers = List.generate(
    _totalCells,
    (index) => TextEditingController(),
  );

  late List<Color> _fillColors = List.generate(
    _totalCells,
    (index) => Colors.transparent,
  );

  late final List<String> _colorTypes = List.generate(
    _totalCells,
    (index) => "surface",
  );

  late final List<String?> _hintLetters = List.filled(_totalCells, null);

  List<String> words = [];
  List<String> c_words = [];
  List<int> revealedIndices = [];
  final bool _readOnly = true;
  Map<String, Color> keyColors = {};

  final List<AnimationController> _shakeControllers = [];
  final List<Animation<double>> _shakeAnimations = [];

  final List<AnimationController> _scaleControllers = [];
  final List<Animation<double>> _scaleAnimations = [];

  late final ConfettiController _confettiController;

  /// Per-mode progress level lives in a global in helper.dart. Route reads and
  /// writes through the correct one based on word length.
  int get _modeLevel => switch (_wordLength) {
    3 => currentThreeModeLevel,
    4 => currentFourModeLevel,
    _ => currentFiveModeLevel,
  };

  set _modeLevel(int value) {
    switch (_wordLength) {
      case 3:
        currentThreeModeLevel = value;
        break;
      case 4:
        currentFourModeLevel = value;
        break;
      default:
        currentFiveModeLevel = value;
    }
  }

  String get _lengthErrorKey => switch (_wordLength) {
    3 => 'three_letter_error',
    4 => 'four_letter_error',
    _ => 'five_letter_error',
  };

  @override
  void initState() {
    super.initState();
    _loadWordsFromJson();
    _loadUserData();
    _correctWord = widget.correctWord;
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );

    for (int i = 0; i < _rows; i++) {
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

    for (int i = 0; i < _totalCells; i++) {
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
    final dir = 'assets/words/${_wordLength}_letters';
    final jsonString = await rootBundle.loadString(
      '$dir/${_wordLength}_letter_words_all.json',
    );
    final jsonString2 = await rootBundle.loadString(
      '$dir/${_wordLength}_letter_answers.json',
    );

    final wordsList = await parseWords(jsonString, 'words');
    final cWordsList = await parseWords(jsonString2, 'c_words');

    setState(() {
      words = wordsList;
      c_words = cWordsList;
    });
  }

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
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color.fromARGB(94, 131, 131, 131),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              width: 1.5,
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer, size: 25),
              const SizedBox(width: 5),
              Text(
                _gameTimer.formattedTime,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            onPressed: () {
              showStatsDialog(context);
            },
            icon: const Icon(Icons.analytics),
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
          const Spacer(),
          for (int i = 0; i < _rows; i++)
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
                      for (int j = _wordLength - 1; j >= 0; j--)
                        _buildCell(i * _wordLength + j),
                    ],
                  ),
                );
              },
            ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            maxBlastForce: 20,
            minBlastForce: 5,
            gravity: 0.2,
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

  Widget _buildCell(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 3),
      child: SizedBox(
        height: 60,
        width: 60,
        child: AnimatedBuilder(
          animation: _scaleAnimations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimations[index].value,
              child: child,
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_controllers[index].text.isEmpty &&
                  _hintLetters[index] != null)
                Text(
                  _hintLetters[index]!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              TextField(
                controller: _controllers[index],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                readOnly: _readOnly,
                textAlign: TextAlign.center,
                maxLength: 1,
                inputFormatters: [LengthLimitingTextInputFormatter(1)],
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  fillColor: _fillColors[index],
                  filled: true,
                  counterText: '',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String messageKey) {
    _vibrateTwice();
    _shakeCurrentRow();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        dismissDirection: DismissDirection.horizontal,
        duration: const Duration(seconds: 2),
        content: Text(
          AppLocalizations.of(context).translate(messageKey),
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
  }

  void _revealHint() async {
    // Bail out if the game is over (won, or all rows used). After the final
    // guess _currentRow has advanced past the grid, so computing startIndex
    // here would index out of bounds.
    if (gameWon || _currentRow >= _rows) {
      _showErrorSnackBar('no_hint_available');
      return;
    }

    if (_diamonds < 15) {
      _showErrorSnackBar('not_enough_diamonds');
      return;
    }

    int startIndex = _currentRow * _wordLength;
    int endIndex = startIndex + _wordLength - 1;

    // Only consider letters already entered in the CURRENT row, so a letter
    // typed in an earlier (wrong) guess doesn't permanently block hints.
    Set<String> guessedThisRow = {
      for (int i = startIndex; i <= endIndex; i++)
        if (_controllers[i].text.trim().isNotEmpty) _controllers[i].text.trim(),
    };

    List<int> availableIndices = [];

    for (int i = startIndex; i <= endIndex; i++) {
      final letter = _correctWord[i % _wordLength];
      // Skip positions already revealed, already filled by the user, or whose
      // letter the user has already placed in this row.
      if (!revealedIndices.contains(i) &&
          _controllers[i].text.trim().isEmpty &&
          !guessedThisRow.contains(letter)) {
        availableIndices.add(i);
      }
    }

    if (availableIndices.isEmpty) {
      _showErrorSnackBar('no_hint_available');
      return;
    }

    int randomIndex =
        availableIndices[Random().nextInt(availableIndices.length)];
    String letter = _correctWord[randomIndex % _wordLength];
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

  void _updateFillColors() {
    final newFillColors = List<Color>.from(_fillColors);
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

  void _insertText(String myText) {
    if ((_currentTextfield < _totalCells && _lettersInRow < _wordLength) &&
        gameWon == false) {
      final controller = _controllers[_currentTextfield];

      controller.text = myText;

      setState(() {
        _triggerPopUp(_currentTextfield);
        _currentTextfield++;
        _lettersInRow++;
      });
    }
  }

  void _backspace() {
    if ((_currentTextfield > 0 && _lettersInRow > 0) && gameWon == false) {
      setState(() {
        _currentTextfield--;
        _lettersInRow--;
      });

      _controllers[_currentTextfield].clear();
    }
  }

  void _submit() async {
    if (_currentTextfield % _wordLength != 0 || _lettersInRow != _wordLength) {
      _showErrorSnackBar(_lengthErrorKey);
      return;
    }

    List<String> _currentWordList = [];
    String _currentWord = "";
    String _guessedLetter;

    int startIndex = _currentTextfield - _wordLength;
    int endIndex = _currentTextfield - 1;

    List<String> _deconstructedCorrectWord = _correctWord.split('');
    Map<String, int> letterCounts = {};
    for (var letter in _deconstructedCorrectWord) {
      letterCounts[letter] = (letterCounts[letter] ?? 0) + 1;
    }

    for (int i = startIndex; i <= endIndex; i++) {
      _currentWordList.add(_controllers[i].text);
    }
    _currentWord = _currentWordList.join("");

    if (!words.contains(_currentWord)) {
      _showErrorSnackBar('not_in_library');
      return;
    }

    if (_currentWord == _correctWord) {
      _confettiController.play();
      for (int k = startIndex; k <= endIndex; k++) {
        _guessedLetter = _controllers[k].text;
        _fillColors[k] = Theme.of(context).colorScheme.onPrimary;
        keyColors[_guessedLetter] = Theme.of(context).colorScheme.onPrimary;
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
      }

      if (_gameTimer.elapsedSeconds < 120 && timeWinStreak == 0) {
        setState(() {
          timeWinStreak++;
        });
        await UserDataService().awardDiamonds(30);
      }

      await UserDataService().recordGame(
        won: true,
        guesses: _currentRow + 1, // row index starts at 0
      );

      showDefinitionDialog(context, _correctWord);

      _modeLevel++;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({'currentLevel$_wordLength': _modeLevel});

      final int reward = calculatePoints(
        "Mode $_wordLength",
        _currentRow,
        _hintsUsed,
      );
      points += reward;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .set({
            // Write the cumulative total, not an increment of it. `points` is
            // loaded at startup and already includes this win's reward.
            'points': points,
            'username':
                FirebaseAuth.instance.currentUser?.email?.split('@').first ??
                'Guest',
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } else {
      for (int i = startIndex, j = 0; i <= endIndex; i++, j++) {
        _guessedLetter = _controllers[i].text;
        if (_guessedLetter == _deconstructedCorrectWord[j]) {
          _fillColors[i] = Theme.of(context).colorScheme.onPrimary;
          keyColors[_guessedLetter] = Theme.of(context).colorScheme.onPrimary;
          _colorTypes[i] = "onPrimary";
          letterCounts[_guessedLetter] = letterCounts[_guessedLetter]! - 1;
        }
      }

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

      if (_currentTextfield == _totalCells && gameWon == false) {
        winStreak = 0; // ← FIX: reset streak immediately
        setState(() {
          gameWon = false;
          _gameTimer.stop();
        });

        await UserDataService().recordGame(won: false);

        await UserDataService().saveStreaks(
          winStreak: winStreak,
          dailyWinStreak: dailyWinStreak,
          timeWinStreak: timeWinStreak,
          points: points,
        );

        incorrectWordDialog(context);
      }
    }

    _currentWordList.clear();
    _lettersInRow = 0;
    _currentRow++;

    await UserDataService().addGottenWord(_correctWord);

    await UserDataService().saveStreaks(
      winStreak: winStreak,
      dailyWinStreak: dailyWinStreak,
      timeWinStreak: timeWinStreak,
      points: points,
    );
  }
}
