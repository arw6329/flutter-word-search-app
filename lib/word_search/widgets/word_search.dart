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
    WordSearch({super.key, required this.rows, required this.columns, required List<String> words, this.onSolve, this.onSerializedStateChange}):
        _initialPuzzleWidgetSerializedState = null,
        _wordsMap = normalizeWords(words);

    WordSearch._fromDeserialized({super.key, required WordSearchSerializableState state, required this.onSolve, required this.onSerializedStateChange}):
        _initialPuzzleWidgetSerializedState = state.internalPuzzleWidgetState,
        _wordsMap = state.wordsMap;

    factory WordSearch.fromSerializedState({Key? key, required WordSearchSerializableState state, onSolve, void Function(WordSearchSerializableState state)? onSerializedStateChange}) {
        return WordSearch._fromDeserialized(key: key, state: state, onSolve: onSolve, onSerializedStateChange: onSerializedStateChange);
    }

    late final int rows;
    late final int columns;
    final Map<String, String> _wordsMap;
    final void Function()? onSolve;
    final void Function(WordSearchSerializableState state)? onSerializedStateChange;

    final WordSearchPuzzleSerializableState? _initialPuzzleWidgetSerializedState;

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
        if(widget._initialPuzzleWidgetSerializedState != null) {
            _solvedWords.addAll(widget._initialPuzzleWidgetSerializedState!.solvedWords.map((placement) => placement.word));
            _puzzle = WordSearchPuzzle.fromSerializedState(
                state: widget._initialPuzzleWidgetSerializedState!,
                onSolveWord: (word) {
                    setState(() {
                        _solvedWords.add(word);
                    });
                },
                onSolve: () {
                    widget.onSolve?.call();
                },
                onSerializedStateChange: widget.onSerializedStateChange == null ? null : (state) {
                    widget.onSerializedStateChange!(WordSearchSerializableState(wordsMap: widget._wordsMap, internalPuzzleWidgetState: state));
                }
            );
            widget.rows = _puzzle!.rows;
            widget.columns = _puzzle!.columns;
        } else {
            _puzzle = WordSearchPuzzle(
                rows: widget.rows,
                columns: widget.columns,
                words: widget._wordsMap.keys.toList(),
                onSolveWord: (word) {
                    setState(() {
                        _solvedWords.add(word);
                    });
                },
                onSolve: () {
                    widget.onSolve?.call();
                },
                onSerializedStateChange: widget.onSerializedStateChange == null ? null : (state) {
                    widget.onSerializedStateChange!(WordSearchSerializableState(wordsMap: widget._wordsMap, internalPuzzleWidgetState: state));
                }
            );
        }
    }

    @override
    Widget build(BuildContext context) {
        return Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

class WordSearchSerializableState {
    const WordSearchSerializableState({required this.wordsMap, required this.internalPuzzleWidgetState});

    final Map<String, String> wordsMap;
    final WordSearchPuzzleSerializableState internalPuzzleWidgetState;

    Map toJson() => {
        'wordsMap': wordsMap,
        'internalPuzzleWidgetState': internalPuzzleWidgetState
    };

    factory WordSearchSerializableState.fromJson(Map<String, dynamic> jsonObject) {
        return WordSearchSerializableState(
            wordsMap: (jsonObject['wordsMap'] as Map).cast<String, String>(),
            internalPuzzleWidgetState: WordSearchPuzzleSerializableState.fromJson(jsonObject['internalPuzzleWidgetState'])
        );
    }
}
