// ignore_for_file: sort_child_properties_last, unused_field, no_leading_underscores_for_local_identifiers, unused_local_variable, constant_pattern_never_matches_value_type, use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:math' show sin, pi;
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

class DailyMode extends StatefulWidget {
  const DailyMode({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DailyMode();
  }
}

class _DailyMode extends State<DailyMode> with TickerProviderStateMixin {
  late final String _uid;
  late GameTimer _gameTimer;
  bool gameWon = false;
  int _currentTextfield = 0;
  int _fiveLettersStop = 0;
  String _dailyWord = '';
  int _currentRow = 0;
  int _diamonds = 0;
  final _userData = UserDataService();
  final List<TextEditingController> _controllers = List.generate(
    35,
    (index) => TextEditingController(),
  );
  List<Color> _fillColors = List.generate(35, (index) => Colors.transparent);
  List<String> _colorTypes = List.generate(35, (index) => "surface");
  int _hintsUsed = 0;
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
    final user = FirebaseAuth.instance.currentUser;
    _uid = user?.uid ?? 'guest';

    _gameTimer = GameTimer(
      onTick: () {
        if (!mounted) return;
        setState(() {});
      },
    );

    // Set up animations
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

    _initializeGame();
    _loadUserData();
  }

  String _key(String base) => '${base}_$_uid';

  Future<void> _loadUserData() async {
    final amount = await _userData.loadDiamonds();
    if (!mounted) return;
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
    final data = json.decode(jsonString);
    final data2 = json.decode(jsonString2);
    if (!mounted) return;
    setState(() {
      words = List<String>.from(data['words']);
      c_words = List<String>.from(data2['c_words']);
    });
  }

  Future<void> _initializeGame() async {
    await _loadWordsFromJson();
    final bool isNewDay = await _initializeDailyWord();
    if (gameWon) {
      _gameTimer.stop();
    } else {
      _gameTimer.start(reset: isNewDay);
    }
    if (!mounted) return;
    setState(() {});
  }

  Future<bool> _initializeDailyWord() async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateTime.now().toIso8601String().substring(0, 10);
    final String dateKey = _key('daily_word_date');
    final String wordKey = _key('daily_word');

    String? storedDate = prefs.getString(dateKey);
    if (storedDate == today) {
      _dailyWord = prefs.getString(wordKey) ?? '';
      await _loadGameState();
      return false; // not a new day
    } else {
      _dailyWord = _generateDailyWord();
      await prefs.setString(wordKey, _dailyWord);
      await prefs.setString(dateKey, today);
      await _resetGameState();

      // Reset daily-only streaks
      winStreak = 0;
      timeWinStreak = 0;
      await UserDataService().saveStreaks(
        winStreak: winStreak,
        dailyWinStreak: dailyWinStreak,
        timeWinStreak: timeWinStreak,
        points: points,
      );
      return true; // new day
    }
  }

  String _generateDailyWord() {
    final int seed =
        DateTime.now().millisecondsSinceEpoch ~/ (1000 * 60 * 60 * 24);
    final random = Random(seed);
    final int wordIndex = random.nextInt(c_words.length);
    return c_words[wordIndex];
  }

  Future<void> _resetGameState() async {
    final prefs = await SharedPreferences.getInstance();
    gameWon = false;
    _currentRow = 0;
    _currentTextfield = 0;
    revealedIndices.clear();
    for (var controller in _controllers) {
      controller.clear();
    }
    // Initialize color types to "surface"
    _colorTypes = List.generate(35, (index) => "surface");
    _fillColors = List.generate(35, (index) => Colors.transparent);
    for (int i = 0; i < 35; i++) {
      _hintLetters[i] = null;
    }
    _hintsUsed = 0;

    await prefs.setBool(_key('game_won'), false);
    await prefs.setInt(_key('current_row'), 0);
    await prefs.setInt(_key('current_textfield'), 0);
    await prefs.setStringList(_key('revealed_indices'), []);
    await prefs.setStringList(
      _key('current_guesses'),
      List.generate(35, (_) => ""),
    );
    await prefs.setStringList(
      _key('color_types'),
      List.generate(35, (_) => "surface"),
    );
    await prefs.setInt(_key('game_timer'), 0);
  }

  Future<void> _loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    gameWon = prefs.getBool(_key('game_won')) ?? false;
    _currentRow = prefs.getInt(_key('current_row')) ?? 0;
    _currentTextfield = prefs.getInt(_key('current_textfield')) ?? 0;

    // Load revealed indices
    List<String>? savedRevealed = prefs.getStringList(_key('revealed_indices'));
    revealedIndices = savedRevealed?.map((e) => int.parse(e)).toList() ?? [];

    // Load guesses into controllers
    List<String>? savedGuesses = prefs.getStringList(_key('current_guesses'));
    if (savedGuesses != null) {
      for (int i = 0; i < savedGuesses.length; i++) {
        _controllers[i].text = savedGuesses[i];
      }
    }

    // Load color types and update fill/colors
    List<String>? savedColorTypes = prefs.getStringList(_key('color_types'));
    if (savedColorTypes != null) {
      _colorTypes = List<String>.from(savedColorTypes);
      _updateFillColors();
      _updateKeyColors();
    }

    // Load timer
    final int savedElapsed = prefs.getInt(_key('game_timer')) ?? 0;
    _gameTimer.elapsedSeconds = savedElapsed;

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _saveGameProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key('game_won'), gameWon);
    await prefs.setInt(_key('current_row'), _currentRow);
    await prefs.setInt(_key('current_textfield'), _currentTextfield);
    await prefs.setStringList(
      _key('revealed_indices'),
      revealedIndices.map((e) => e.toString()).toList(),
    );
    await prefs.setStringList(
      _key('current_guesses'),
      _controllers.map((c) => c.text).toList(),
    );
    await prefs.setStringList(_key('color_types'), _colorTypes);
    await prefs.setInt(_key('game_timer'), _gameTimer.elapsedSeconds);
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
    _saveGameProgress();
    _gameTimer.stop();
    super.dispose();
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
                                        color: Colors.grey,
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

    final int startIndex = _currentRow * 5;
    final int endIndex = startIndex + 4;
    final Set<String> guessed =
        _controllers
            .map((c) => c.text.trim())
            .where((c) => c.isNotEmpty)
            .toSet();
    final List<int> availableIndices = [];
    for (int i = startIndex; i <= endIndex; i++) {
      final letter = _dailyWord[i % 5];
      if (!revealedIndices.contains(i) && !guessed.contains(letter)) {
        availableIndices.add(i);
      }
    }
    if (!gameWon && availableIndices.isNotEmpty) {
      final int randomIndex =
          availableIndices[Random().nextInt(availableIndices.length)];
      final String letter = _dailyWord[randomIndex % 5];
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

  void _updateFillColors() {
    final newFill = List<Color>.from(_fillColors);
    final colorScheme = Theme.of(context).colorScheme;
    for (int i = 0; i < newFill.length; i++) {
      switch (_colorTypes[i]) {
        case "onPrimary":
          newFill[i] = colorScheme.onPrimary;
          break;
        case "onSecondary":
          newFill[i] = colorScheme.onSecondary;
          break;
        case "onError":
          newFill[i] = colorScheme.onError;
          break;
        default:
          newFill[i] = Colors.transparent;
      }
    }
    if (!mounted) return;
    setState(() {
      _fillColors = newFill;
    });
  }

  void _updateKeyColors() {
    final newKeyColors = <String, Color>{};
    final colorScheme = Theme.of(context).colorScheme;
    for (int i = 0; i < _currentTextfield; i++) {
      final String letter = _controllers[i].text;
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
    if (!mounted) return;
    setState(() {
      keyColors = newKeyColors;
    });
  }

  void _insertText(String myText) {
    if (_currentTextfield < 35 && _fiveLettersStop < 5 && !gameWon) {
      final controller = _controllers[_currentTextfield];
      controller.text = myText;
      if (!mounted) return;
      setState(() {
        _triggerPopUp(_currentTextfield);
        _currentTextfield++;
        _fiveLettersStop++;
      });
    }
  }

  void _backspace() {
    if (_currentTextfield > 0 && _fiveLettersStop > 0 && !gameWon) {
      if (!mounted) return;
      setState(() {
        _currentTextfield--;
        _fiveLettersStop--;
      });
      _controllers[_currentTextfield].clear();
    }
  }

  void _submit() async {
    // 1) Always save the current progress to SharedPreferences
    await _saveGameProgress();

    // 2) Enforce that exactly 5 letters are filled for this row
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

    // 3) Reconstruct the guessed word from the last 5 text fields
    final List<String> currentWordList = [];
    for (int i = _currentTextfield - 5; i < _currentTextfield; i++) {
      currentWordList.add(_controllers[i].text);
    }
    final String currentWord = currentWordList.join("");

    // 4) If the guessed word isn't in your valid-words list, reject it
    if (!words.contains(currentWord)) {
      _vibrateTwice();
      _shakeCurrentRow();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
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

    // 5) Prepare indices and a letter‐count map for coloring hints
    final int startIndex = _currentTextfield - 5;
    final int endIndex = _currentTextfield - 1;
    final List<String> deconstructedCorrect = _dailyWord.split('');
    final Map<String, int> letterCounts = {};
    for (var letter in deconstructedCorrect) {
      letterCounts[letter] = (letterCounts[letter] ?? 0) + 1;
    }

    // 6) If the guess matches the daily word → WIN
    if (currentWord == _dailyWord) {
      // 6a) Color all 5 letters in this row green
      for (int k = startIndex; k <= endIndex; k++) {
        final String guessedLetter = _controllers[k].text;
        _fillColors[k] = Theme.of(context).colorScheme.onPrimary;
        keyColors[guessedLetter] = Theme.of(context).colorScheme.onPrimary;
        _colorTypes[k] = "onPrimary";
      }

      // 6b) Mark gameWon, stop the timer
      if (!mounted) return;
      setState(() {
        gameWon = true;
        _gameTimer.stop();
      });

      // 6c) Win‐3‐in‐a‐row logic
      winStreak++;
      if (winStreak == 3) {
        await UserDataService().awardDiamonds(50);
        winStreak = 0; // reset after awarding
      }

      // 6d) Solve under-2-minutes logic (only once per day)
      if (_gameTimer.elapsedSeconds < 120 && timeWinStreak == 0) {
        timeWinStreak++;
        await UserDataService().awardDiamonds(30);
      }

      // 6e) Seven‐day streak logic
      dailyWinStreak++;
      if (dailyWinStreak == 7) {
        await UserDataService().awardDiamonds(150);
        dailyWinStreak = 0; // reset after awarding
      }

      // 6f) Persist streaks to Firestore (winStreak, dailyWinStreak, timeWinStreak, points)
      await UserDataService().saveStreaks(
        winStreak: winStreak,
        dailyWinStreak: dailyWinStreak,
        timeWinStreak: timeWinStreak,
        points: points,
      );

      // 6g) Record the win (this will bump stats_dist_{row}, plus stats_played, stats_wins, etc.)
      await UserDataService().recordGame(won: true, guesses: _currentRow + 1);

      // 6h) Show the definition popup
      showDefinitionDialog(context, _dailyWord);

      // 6i) Award points based on number of rows and hints
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
      // 7) Coloring logic for a non‐winning guess:

      // 7a) First pass: correct letters in correct positions → green
      for (int i = startIndex, j = 0; i <= endIndex; i++, j++) {
        final String guessedLetter = _controllers[i].text;
        if (guessedLetter == deconstructedCorrect[j]) {
          _fillColors[i] = Theme.of(context).colorScheme.onPrimary;
          keyColors[guessedLetter] = Theme.of(context).colorScheme.onPrimary;
          _colorTypes[i] = "onPrimary";
          letterCounts[guessedLetter] = letterCounts[guessedLetter]! - 1;
        }
      }

      // 7b) Second pass: correct letters in wrong positions → orange; else → gray
      for (int i = startIndex, j = 0; i <= endIndex; i++, j++) {
        final String guessedLetter = _controllers[i].text;
        if (_fillColors[i] != Theme.of(context).colorScheme.onPrimary) {
          if (letterCounts.containsKey(guessedLetter) &&
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

      // 8) If this was the final (7th) row and gameWon remains false → LOSS
      if (_currentTextfield == 35 && !gameWon) {
        // 8a) Reset winStreak to zero
        winStreak = 0;

        // 8b) Record the loss (no guesses argument, so distribution is not bumped)
        await UserDataService().recordGame(won: false);

        // 8c) Persist streaks to Firestore (winStreak = 0, daily/time unchanged, points unchanged)
        await UserDataService().saveStreaks(
          winStreak: winStreak,
          dailyWinStreak: dailyWinStreak,
          timeWinStreak: timeWinStreak,
          points: points,
        );

        // 8d) Show “Incorrect” dialog with the correct word underlined
        _incorrectWordDialog();
      }
    }

    // 9) Advance to the next row, mark this word as “gotten,” and save streaks again
    _fiveLettersStop = 0;
    _currentRow++;
    await UserDataService().addGottenWord(_dailyWord);

    await UserDataService().saveStreaks(
      winStreak: winStreak,
      dailyWinStreak: dailyWinStreak,
      timeWinStreak: timeWinStreak,
      points: points,
    );
  }

  void _incorrectWordDialog() {
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
                    text:
                        '${AppLocalizations.of(context).translate('correct_word')} ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text: _dailyWord,
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
                                'https://www.almaany.com/ar/dict/ar-ar/$_dailyWord/?',
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
