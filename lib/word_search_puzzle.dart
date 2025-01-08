import 'dart:developer' as dev;
import 'dart:math';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:word_search_app/puzzle_builder.dart';
import 'package:word_search_app/word_search_highlight.dart';

List<String> normalizeWords(List<String> words) {
    return words.map((word) => word.toUpperCase()).toList();
}

class WordSearchPuzzle extends StatefulWidget {
    WordSearchPuzzle({super.key, required this.rows, required this.columns, required List<String> words}):
        _words = normalizeWords(words),
        _puzzleBuilder = PuzzleBuilder(rows: rows, columns: columns, words: normalizeWords(words));

    final int rows;
    final int columns;

    final List<String> _words;
    final PuzzleBuilder _puzzleBuilder;

    @override
    State<WordSearchPuzzle> createState() => _WordSearchPuzzleState();
}

class _WordSearchPuzzleState extends State<WordSearchPuzzle> {
    final Set<Placement> _solvedWords = {};

    int? _activeHighlightStartRow;
    int? _activeHighlightStartColumn;
    int? _pointerCurrentRow;
    int? _pointerCurrentColumn;

    final GlobalKey _gridView = GlobalKey();

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

                final matchedWord = widget._words.firstWhereOrNull(
                    (word) => word == highlightedWord || word == highlightedWord.split('').reversed.join('')
                );

                if(matchedWord != null && !_isWordSolved(matchedWord)) {
                    dev.log('Solved word $matchedWord');
                    _solvedWords.add(Placement(row: _activeHighlightStartRow!, column: _activeHighlightStartColumn!, direction: direction, word: matchedWord));
                }
            }

            _activeHighlightStartColumn = null;
            _activeHighlightStartRow = null;
        });
    }

    _getHighlights(BoxConstraints constraints) {
        return [
            if(_activeHighlightStartColumn != null) WordSearchHighlight(
                constraints: constraints,
                puzzleRows: widget.rows,
                puzzleColumns: widget.columns,
                startX: _activeHighlightStartColumn!,
                startY: _activeHighlightStartRow!,
                endX: _pointerCurrentColumn!,
                endY: _pointerCurrentRow!
            ),
            ..._solvedWords.map((placement) => WordSearchHighlight.fromPlacement(
                constraints: constraints,
                puzzleRows: widget.rows,
                puzzleColumns: widget.columns,
                placement: placement
            ))
        ];
    }

    bool _isWordSolved(String word) {
        return _solvedWords.any((placement) => placement.word == word);
    }

    _solve() {
        setState(() {
            _solvedWords.addAll(widget._puzzleBuilder.placements
                .where((placement) => !_isWordSolved(placement.word)));
        });
    }

    @override
    Widget build(BuildContext context) {
        return Container(
            color: Colors.white,
            margin: EdgeInsets.all(5),
            child: Container(
                padding: EdgeInsets.all(5),
                child: Flexible(
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
                                                    
                                            return Center(
                                                child: Text(widget._puzzleBuilder.charAt(row, column))
                                            );
                                        })
                                    ),
                                )
                            ]
                        ),
                    ),
                )
            )
        );
    }
}