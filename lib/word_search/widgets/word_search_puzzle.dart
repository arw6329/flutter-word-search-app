import 'dart:developer' as dev;
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:word_search_app/word_search/puzzle_builder.dart';
import 'package:word_search_app/word_search/widgets/word_search_highlight.dart';

class WordSearchPuzzle extends StatefulWidget {
    WordSearchPuzzle({super.key, required this.rows, required this.columns, required this.words, required FillStrategy fillStrategy, required this.onSolveWord, required this.onSolve, this.onSerializedStateChange}):
        _initialSolvedWords = {},
        _puzzleBuilder = PuzzleBuilder(rows: rows, columns: columns, words: words, fillStrategy: fillStrategy);

    WordSearchPuzzle._fromDeserialized({super.key, required PuzzleBuilder puzzleBuilder, required Set<Placement> initialSolvedWords, required this.onSolveWord, required this.onSolve, this.onSerializedStateChange}):
        words = puzzleBuilder.placements.map((placement) => placement.word).toList(),
        rows = puzzleBuilder.rows,
        columns = puzzleBuilder.columns,
        _puzzleBuilder = puzzleBuilder,
        _initialSolvedWords = initialSolvedWords;

    factory WordSearchPuzzle.fromSerializedState({Key? key, required WordSearchPuzzleSerializableState state, required onSolveWord, required onSolve, void Function(WordSearchPuzzleSerializableState state)? onSerializedStateChange}) {
        return WordSearchPuzzle._fromDeserialized(
            key: key,
            puzzleBuilder: state.puzzleBuilder,
            initialSolvedWords: state.solvedWords.toSet(),
            onSolveWord: onSolveWord,
            onSolve: onSolve,
            onSerializedStateChange: onSerializedStateChange
        );
    }

    final int rows;
    final int columns;
    final List<String> words;
    final void Function(String word) onSolveWord;
    final void Function() onSolve;
    final void Function(WordSearchPuzzleSerializableState state)? onSerializedStateChange;

    final PuzzleBuilder _puzzleBuilder;
    final Set<Placement> _initialSolvedWords;
    final int _colorRandomSeed = Random().nextInt(1000000);

    @override
    State<WordSearchPuzzle> createState() => WordSearchPuzzleState();
}

class WordSearchPuzzleState extends State<WordSearchPuzzle> {
    final Set<Placement> _solvedWords = {};

    int? _activeHighlightStartRow;
    int? _activeHighlightStartColumn;
    int? _pointerCurrentRow;
    int? _pointerCurrentColumn;

    final GlobalKey _gridView = GlobalKey();

    @override
    void initState() {
        super.initState();
        _solvedWords.addAll(widget._initialSolvedWords);
    }

    (int row, int column) _pointerEventToRowAndColumn(PointerEvent event) {
        final row = (event.localPosition.dy / (_gridView.currentContext!.size!.height / widget.rows))
            .floor().clamp(0, widget.rows - 1);
        final column = (event.localPosition.dx / (_gridView.currentContext!.size!.width / widget.columns))
            .floor().clamp(0, widget.columns - 1);

        return (row, column);
    }

    _startHighlight(pointerDownEvent) {
        setState(() {
            var (row, column) = _pointerEventToRowAndColumn(pointerDownEvent);
            _activeHighlightStartRow = row;
            _activeHighlightStartColumn = column;
            _pointerCurrentRow = row;
            _pointerCurrentColumn = column;
        });
    }

    _updateHighlight(pointerMoveEvent) {
        final (row, column) = _pointerEventToRowAndColumn(pointerMoveEvent);

        final isValidLocation = column - _activeHighlightStartColumn! == 0
            || row - _activeHighlightStartRow! == 0
            || (column - _activeHighlightStartColumn!).abs() == (row - _activeHighlightStartRow!).abs();

        final needsUpdated = row != _pointerCurrentRow || column != _pointerCurrentColumn;

        if(isValidLocation && needsUpdated) {
            setState(() {
                _pointerCurrentRow = row;
                _pointerCurrentColumn = column;
            });
        }
    }

    _cancelHighlight(_) {
        setState(() {
            if(_activeHighlightStartColumn != null) {
                final direction = Direction.fromStartAndEndPoints(_activeHighlightStartColumn!, _activeHighlightStartRow!, _pointerCurrentColumn!, _pointerCurrentRow!);
                final length = max(
                    (_pointerCurrentColumn! - _activeHighlightStartColumn!).abs() + 1,
                    (_pointerCurrentRow! - _activeHighlightStartRow!).abs() + 1
                );

                var highlightedWord = widget._puzzleBuilder.sequenceAt(
                    _activeHighlightStartColumn!, _activeHighlightStartRow!, direction, length
                );

                final matchedWord = widget.words.firstWhereOrNull(
                    (word) => word == highlightedWord || word == highlightedWord.split('').reversed.join('')
                );

                if(matchedWord != null && !_isWordSolved(matchedWord)) {
                    dev.log('Solved word $matchedWord');
                    _solvedWords.add(Placement(row: _activeHighlightStartRow!, column: _activeHighlightStartColumn!, direction: direction, word: matchedWord));
                    
                    widget.onSolveWord(matchedWord);

                    if(widget.onSerializedStateChange != null && _solvedWords.length != widget.words.length) {
                        widget.onSerializedStateChange!.call(
                            WordSearchPuzzleSerializableState(
                                solvedWords: _solvedWords.toList(),
                                puzzleBuilder: widget._puzzleBuilder
                            )
                        );
                    }

                    if(_solvedWords.length == widget.words.length) {
                        widget.onSolve();
                    }
                }
            }

            _activeHighlightStartColumn = null;
            _activeHighlightStartRow = null;
        });
    }

    _getHighlights(BoxConstraints constraints) {
        final random = Random(widget._colorRandomSeed);
        return [
            ..._solvedWords.map((placement) => WordSearchHighlight.fromPlacement(
                constraints: constraints,
                puzzleRows: widget.rows,
                puzzleColumns: widget.columns,
                placement: placement,
                color: WordSearchHighlightColors.random(random)
            )),
            if(_activeHighlightStartColumn != null) WordSearchHighlight(
                constraints: constraints,
                puzzleRows: widget.rows,
                puzzleColumns: widget.columns,
                startX: _activeHighlightStartColumn!,
                startY: _activeHighlightStartRow!,
                endX: _pointerCurrentColumn!,
                endY: _pointerCurrentRow!,
                color: WordSearchHighlightColors.random(random)
            )
        ];
    }

    bool _isWordSolved(String word) {
        return _solvedWords.any((placement) => placement.word == word);
    }

    solve() {
        setState(() {
            final unsolvedWords = widget._puzzleBuilder.placements.where((placement) => !_isWordSolved(placement.word));
            for(final placement in unsolvedWords) {
                _solvedWords.add(placement);
                widget.onSolveWord(placement.word);
            }
            widget.onSolve();
        });
    }

    @override
    Widget build(BuildContext context) {
        return Container(
            color: Theme.of(context).colorScheme.inverseSurface,
            margin: EdgeInsets.all(5),
            child: Container(
                padding: EdgeInsets.all(5),
                child: AspectRatio(
                    aspectRatio: widget.columns / widget.rows,
                    child: Stack(
                        children: [
                            IgnorePointer(
                                child: LayoutBuilder(
                                    builder: (BuildContext context, BoxConstraints constraints) {
                                        return Stack(
                                            children: _getHighlights(constraints)
                                        );
                                    },
                                ),
                            ),
                            Listener(
                                onPointerDown: _startHighlight,
                                onPointerMove: _updateHighlight,
                                onPointerUp: _cancelHighlight,
                                onPointerCancel: _cancelHighlight,
                                child: GridView.count(
                                    key: _gridView,
                                    physics: const NeverScrollableScrollPhysics(),
                                    childAspectRatio: 1,
                                    crossAxisCount: widget.columns,
                                    shrinkWrap: true,
                                    children: List.generate(widget.rows * widget.columns, (index) {
                                        var row = (index / widget.columns).floor();
                                        var column = index % widget.columns;
                                        
                                        bool isPlacedWord = false;
                                        if(kDebugMode) {
                                            isPlacedWord = widget._puzzleBuilder.placements.any((placement) => placement.containsPoint((row, column)));
                                        }

                                        return Center(
                                            child: Text(
                                                widget._puzzleBuilder.charAt(row, column),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: isPlacedWord ? Colors.red : Color.fromRGBO(22, 22, 22, 1)
                                                )
                                            )
                                        );
                                    })
                                )
                            )
                        ]
                    )
                )
            )
        );
    }
}

class WordSearchPuzzleSerializableState {
    const WordSearchPuzzleSerializableState({required this.solvedWords, required this.puzzleBuilder});

    final List<Placement> solvedWords;
    final PuzzleBuilder puzzleBuilder;

    Map toJson() => {
        'solvedWords': solvedWords,
        'puzzleBuilder': puzzleBuilder
    };

    factory WordSearchPuzzleSerializableState.fromJson(Map<String, dynamic> jsonObject) {
        return WordSearchPuzzleSerializableState(
            solvedWords: (jsonObject['solvedWords'] as List).map((placementJson) => Placement.fromJson(placementJson)).toList(),
            puzzleBuilder: PuzzleBuilder.fromJson(jsonObject['puzzleBuilder'])
        );
    }
}
