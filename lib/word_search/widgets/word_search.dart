import 'package:flutter/material.dart';
import 'package:word_search_app/word_search/puzzle_builder.dart';
import 'package:word_search_app/word_search/widgets/word_bank.dart';
import 'package:word_search_app/word_search/widgets/word_search_puzzle.dart';

class WordSearch extends StatefulWidget {
    const WordSearch({
        super.key,
        required this.initialState,
        required this.onSolve,
        required this.onSerializedStateChange
    });

    final void Function()? onSolve;
    final void Function(WordSearchSerializableState state)? onSerializedStateChange;
    final WordSearchSerializableState initialState;

    @override
    State<WordSearch> createState() => WordSearchState();
}

class WordSearchState extends State<WordSearch> {
    final Set<String> _solvedWords = {};
    WordSearchPuzzle? _puzzle;
    final GlobalKey _puzzleKey = GlobalKey();

    // prevents regenerating puzzle on redraw
    @override
    void initState() {
        super.initState();
        _solvedWords.addAll(widget.initialState.internalPuzzleWidgetState.solvedWords.map((placement) => placement.word));
        _puzzle = WordSearchPuzzle(
            key: _puzzleKey,
            state: widget.initialState.internalPuzzleWidgetState,
            onSolveWord: (word) {
                setState(() {
                    _solvedWords.add(word);
                });
            },
            onSolve: () {
                widget.onSolve?.call();
            },
            onSerializedStateChange: widget.onSerializedStateChange == null ? null : (state) {
                widget.onSerializedStateChange!(WordSearchSerializableState(wordsMap: widget.initialState.wordsMap, internalPuzzleWidgetState: state));
            }
        );
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
                        words: widget.initialState.wordsMap,
                        solvedWords: _solvedWords
                    )
                )
            ]
        );
    }

    solve() {
        (_puzzleKey.currentState as WordSearchPuzzleState).solve();
    }
}

class WordSearchSerializableState {
    const WordSearchSerializableState({required this.wordsMap, required this.internalPuzzleWidgetState});

    WordSearchSerializableState.newUnsolved(this.wordsMap, PuzzleBuilder puzzleBuilder):
        internalPuzzleWidgetState = WordSearchPuzzleSerializableState.newUnsolved(puzzleBuilder);

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
