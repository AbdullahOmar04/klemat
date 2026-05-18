import 'package:flutter/material.dart';
import 'package:klemat/helper.dart';
import 'package:klemat/themes/app_localization.dart'; // Make sure `gottenWords` is declared there and persists

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  List<String> _words = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final words = await UserDataService().loadGottenWords();
    setState(() {
      _words = words;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('library')),
        centerTitle: true,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _words.isEmpty
              ? Center(
                child: Text(
                  AppLocalizations.of(
                    context,
                  ).translate('no_words_collected_yet'),
                ),
              )
              : ListView.builder(
                itemCount: _words.length,
                itemBuilder: (context, index) {
                  final word = _words[index];
                  return ListTile(
                    leading: const Icon(Icons.book_outlined),
                    title: Text(word, style: const TextStyle(fontSize: 20)),
                    onTap: () => showDefinitionDialog(context, word),
                  );
                },
              ),
    );
  }
}
