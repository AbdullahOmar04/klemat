import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klemat/helper.dart';

class CustomKeyboard extends StatelessWidget {
  final ValueSetter<String> onTextInput;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;
  final VoidCallback onRevealHint;
  final Map<String, Color> keyColors;

  const CustomKeyboard({
    super.key,
    required this.onTextInput,
    required this.onBackspace,
    required this.onSubmit,
    required this.onRevealHint,
    required this.keyColors,
  });

  void _textInputHandler(String text) => onTextInput.call(text);
  void _backspaceHandler() => onBackspace.call();
  void _submitHandler() => onSubmit.call();
  void _revealHintHandler() => onRevealHint.call();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double keyboardHeight = screenHeight * 0.26;
    return Container(
      height: keyboardHeight,
      padding: const EdgeInsets.all(5.0),
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildRowOne(context),
          buildRowTwo(context),
          buildRowThree(context),
          buildSubmitRow(context),
        ],
      ),
    );
  }

  Expanded buildRowOne(BuildContext context) {
    return Expanded(
      child: Row(
        children:
            ['ض', 'ص', 'ث', 'ق', 'ف', 'غ', 'ع', 'ه', 'خ', 'ح', 'ج', 'إ', 'أ']
                .map(
                  (letter) => TextKey(
                    text: letter,
                    onTextInput: _textInputHandler,
                    color:
                        keyColors[letter] ??
                        Theme.of(context).colorScheme.primary,
                  ),
                )
                .toList(),
      ),
    );
  }

  Expanded buildRowTwo(BuildContext context) {
    return Expanded(
      child: Row(
        children:
            ['ش', 'س', 'ي', 'ب', 'ل', 'ا', 'ت', 'ن', 'م', 'ك', 'ذ', 'د']
                .map(
                  (letter) => TextKey(
                    text: letter,
                    onTextInput: _textInputHandler,
                    color:
                        keyColors[letter] ??
                        Theme.of(context).colorScheme.primary,
                  ),
                )
                .toList(),
      ),
    );
  }

  Expanded buildRowThree(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          ...['ئ', 'ء', 'ؤ', 'ر', 'ى', 'ة', 'و', 'ز', 'ط', 'ظ'].map(
            (letter) => TextKey(
              text: letter,
              onTextInput: _textInputHandler,
              color: keyColors[letter] ?? Theme.of(context).colorScheme.primary,
            ),
          ),
          BackspaceKey(flex: 2, onBackspace: _backspaceHandler),
        ],
      ),
    );
  }

  Widget buildSubmitRow(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          SubmitKey(flex: 3, onSubmit: _submitHandler),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Material(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).colorScheme.primary,
                child: InkWell(
                  onTap: () async {
                    _revealHintHandler();
                    triggerHapticFeedback();
                  },
                  child: const Center(
                    child: Row(
                      children: [
                        SizedBox(width: 20),
                        Icon(Icons.search, size: 30),
                        Column(
                          children: [
                            SizedBox(height: 5),
                            Icon(
                              Icons.diamond_outlined,
                              size: 20,
                              color: Colors.cyan,
                            ),
                            Text('15'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TextKey extends StatelessWidget {
  const TextKey({
    super.key,
    required this.text,
    required this.onTextInput,
    this.flex = 1,
    required this.color,
  });

  final String text;
  final ValueSetter<String> onTextInput;
  final int flex;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Material(
          borderRadius: BorderRadius.circular(5),
          color: color,
          child: InkWell(
            onTap: () async {
              onTextInput.call(text);
              triggerHapticFeedback();
            },
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BackspaceKey extends StatelessWidget {
  const BackspaceKey({super.key, required this.onBackspace, this.flex = 1});

  final VoidCallback onBackspace;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Material(
          borderRadius: BorderRadius.circular(5),
          color: Theme.of(context).colorScheme.primary,
          child: InkWell(
            onTap: () async {
              onBackspace.call();
              triggerHapticFeedback();
            },
            child: Center(
              child: Icon(
                Icons.backspace,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SubmitKey extends StatelessWidget {
  const SubmitKey({super.key, this.flex = 1, required this.onSubmit});

  final int flex;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Material(
          borderRadius: BorderRadius.circular(5),
          color: Theme.of(context).colorScheme.primary,
          child: InkWell(
            onTap: () async {
              onSubmit.call();
              triggerHapticFeedback();
            },
            child: const Center(
              child: Text(
                "إدخال",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


