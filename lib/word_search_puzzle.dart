import 'package:flutter/material.dart';
import 'package:word_search_app/puzzle_builder.dart';
import 'package:word_search_app/util/random.dart';
import 'package:word_search_app/word_search_highlight.dart';

class WordSearchPuzzle extends StatefulWidget {
  WordSearchPuzzle({super.key, required this.rows, required this.columns, required this.words}):
    _puzzleBuilder = PuzzleBuilder(rows: rows, columns: columns, words: words);

  final int rows;
  final int columns;
  final List<String> words;

  final PuzzleBuilder _puzzleBuilder;

  @override
  State<WordSearchPuzzle> createState() => _WordSearchPuzzleState();
}

class _WordSearchPuzzleState extends State<WordSearchPuzzle> {
    final List<WordSearchHighlight> _highlights = [];

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
        _activeHighlightStartX = null;
        _activeHighlightStartY = null;
      });
    }

    @override
    Widget build(BuildContext context) {
        return Container(
            color: Colors.white,
            margin: EdgeInsets.all(5),
            child: Container(
                padding: EdgeInsets.all(5),
                child: Stack(
                    children: [
                        IgnorePointer(
                          child: LayoutBuilder(
                              builder: (BuildContext context, BoxConstraints constraints) {
                                  return Stack(
                                      children: _activeHighlightStartX != null
                                        ? [
                                          WordSearchHighlight(
                                              constraints: constraints,
                                              puzzleRows: widget.rows,
                                              puzzleColumns: widget.columns,
                                              startX: _activeHighlightStartX!,
                                              startY: _activeHighlightStartY!,
                                              endX: _activeHighlightEndX!,
                                              endY: _activeHighlightEndY!
                                          ),
                                          ..._highlights
                                        ]
                                        : widget._puzzleBuilder.placements.map((placement) => WordSearchHighlight(
                                              constraints: constraints,
                                              puzzleRows: widget.rows,
                                              puzzleColumns: widget.columns,
                                              startX: placement.column,
                                              startY: placement.row,
                                              endX: placement.column + placement.direction.dy * (placement.word.length - 1),
                                              endY: placement.row + placement.direction.dx * (placement.word.length - 1)
                                          )).toList()
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
                                        child: Text(widget._puzzleBuilder.charAt(row, column) ?? randomLetter())
                                    )
                                  );
                              })
                          ),
                        )
                    ]
                )
            )
        );
    }
}