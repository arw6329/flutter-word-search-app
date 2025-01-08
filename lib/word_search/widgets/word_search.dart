import 'package:flutter/material.dart';
import 'package:word_search_app/word_search/widgets/word_bank.dart';
import 'package:word_search_app/word_search/widgets/word_search_puzzle.dart';

// maps normalized words to original word for display
// for example { 'SOUTHKOREA': 'South Korea' }
Map<String, String> normalizeWords(List<String> words) {
    return Map.fromEntries(words.map(
        (word) => MapEntry(
            word.toUpperCase().replaceAll(RegExp('[^A-Z]'), ''),
            word
        )
    ));
}

class WordSearch extends StatefulWidget {
    WordSearch({super.key, required this.rows, required this.columns, required List<String> words}):
        _wordsMap = normalizeWords(words);

    final int rows;
    final int columns;
    final Map<String, String> _wordsMap;

    @override
    State<WordSearch> createState() => _WordSearchState();
}

class _WordSearchState extends State<WordSearch> {
    final Set<String> _solvedWords = {};
    WordSearchPuzzle? _puzzle;

    // prevents regenerating puzzle on redraw
    @override
    void initState() {
        super.initState();
        _puzzle = WordSearchPuzzle(
            rows: widget.rows,
            columns: widget.columns,
            words: widget._wordsMap.keys.toList(),
            onSolveWord: (word) {
                setState(() {
                    _solvedWords.add(word);
                });
            },
        );
    }

    @override
    Widget build(BuildContext context) {
        return Flex(
            direction: Axis.vertical,
            children: [
                Flexible(
                    flex: 1,
                    child: _puzzle ?? Container()
                ),
                Flexible(
                    flex: 0,
                    child: WordBank(
                        words: widget._wordsMap,
                        solvedWords: _solvedWords
                    )
                )
            ]
        );
    }
}
