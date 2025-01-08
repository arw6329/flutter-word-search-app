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

    int? _pointerX;
    int? _pointerY;

    int? _activeHighlightStartX;
    int? _activeHighlightStartY;
    int? _activeHighlightEndX;
    int? _activeHighlightEndY;

    _setPointerLocation(int row, int column) {
      setState(() {
        _pointerX = column;
        _pointerY = row;
        
        if(
          _activeHighlightStartX == null
          || _activeHighlightStartY == null
          || _pointerX! - _activeHighlightStartX! == 0
          || _pointerY! - _activeHighlightStartY! == 0
          || (_pointerX! - _activeHighlightStartX!).abs() == (_pointerY! - _activeHighlightStartY!).abs()
        ) {
          _activeHighlightEndX = _pointerX;
          _activeHighlightEndY = _pointerY;
        }
      });
    }

    _startHighlight(_) {
      setState(() {
        _activeHighlightStartX = _pointerX;
        _activeHighlightStartY = _pointerY;
      });
    }

    _cancelHighlight(_) {
      setState(() {
        if(_activeHighlightStartX != null) {
            final direction = Direction.fromStartAndEndPoints(_activeHighlightStartX!, _activeHighlightStartY!, _activeHighlightEndX!, _activeHighlightEndY!);
            final length = max(
                (_activeHighlightEndX! - _activeHighlightStartX!).abs() + 1,
                (_activeHighlightEndY! - _activeHighlightStartY!).abs() + 1
            );

            var highlightedWord = widget._puzzleBuilder.sequenceAt(
                _activeHighlightStartX!, _activeHighlightStartY!, direction, length
            );

            final matchedWord = widget._words.firstWhereOrNull(
                (word) => word == highlightedWord || word == highlightedWord.split('').reversed.join('')
            );

            if(matchedWord != null && !_isWordSolved(matchedWord)) {
                dev.log('Solved word $matchedWord');
                _solvedWords.add(Placement(row: _activeHighlightStartY!, column: _activeHighlightStartX!, direction: direction, word: matchedWord));
            }
        }

        _activeHighlightStartX = null;
        _activeHighlightStartY = null;
      });
    }

    _getHighlights(BoxConstraints constraints) {
        return [
            if(_activeHighlightStartX != null) WordSearchHighlight(
                constraints: constraints,
                puzzleRows: widget.rows,
                puzzleColumns: widget.columns,
                startX: _activeHighlightStartX!,
                startY: _activeHighlightStartY!,
                endX: _activeHighlightEndX!,
                endY: _activeHighlightEndY!
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
                                    onPointerUp: _cancelHighlight,
                                    onPointerCancel: _cancelHighlight,
                                    child: GridView.count(
                                        childAspectRatio: 1,
                                        crossAxisCount: widget.columns,
                                        shrinkWrap: true,
                                        children: List.generate(widget.rows * widget.columns, (index) {
                                            var row = (index / widget.columns).floor();
                                            var column = index % widget.columns;
                                                    
                                            return MouseRegion(
                                                onEnter: (_) {
                                                    _setPointerLocation(row, column);
                                                },
                                                child: Center(
                                                    child: Text(widget._puzzleBuilder.charAt(row, column))
                                                )
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