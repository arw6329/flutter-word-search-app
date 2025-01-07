import 'package:flutter/material.dart';
import 'package:word_search_app/word_search_highlight.dart';

class WordSearchPuzzle extends StatelessWidget {
    const WordSearchPuzzle({super.key, required this.rows, required this.columns});

    final int rows;
    final int columns;

    @override
    Widget build(BuildContext context) {
        return Container(
            color: Colors.red,
            margin: EdgeInsets.all(5),
            child: Container(
                padding: EdgeInsets.all(5),
                child: Stack(
                    children: [
                        GridView.count(
                            childAspectRatio: 1,
                            crossAxisCount: columns,
                            shrinkWrap: true,
                            children: List.generate(rows * columns, (index) {
                                return Container(
                                    color: Colors.blue,
                                    child: Center(
                                        child: Text('X')
                                    ),
                                );
                            })
                        ),
                        LayoutBuilder(
                            builder: (BuildContext context, BoxConstraints constraints) {
                                return Stack(
                                    children: [
                                        WordSearchHighlight(
                                            constraints: constraints,
                                            puzzleRows: rows,
                                            puzzleColumns: columns,
                                            startX: 5,
                                            startY: 3,
                                            endX: 9,
                                            endY: 3
                                        ),
                                        WordSearchHighlight(
                                            constraints: constraints,
                                            puzzleRows: rows,
                                            puzzleColumns: columns,
                                            startX: 10,
                                            startY: 0,
                                            endX: 5,
                                            endY: 0
                                        ),
                                        WordSearchHighlight(
                                            constraints: constraints,
                                            puzzleRows: rows,
                                            puzzleColumns: columns,
                                            startX: 1,
                                            startY: 2,
                                            endX: 1,
                                            endY: 7
                                        ),
                                        WordSearchHighlight(
                                            constraints: constraints,
                                            puzzleRows: rows,
                                            puzzleColumns: columns,
                                            startX: 6,
                                            startY: 6,
                                            endX: 8,
                                            endY: 8
                                        ),
                                        WordSearchHighlight(
                                            constraints: constraints,
                                            puzzleRows: rows,
                                            puzzleColumns: columns,
                                            startX: 10,
                                            startY: 6,
                                            endX: 12,
                                            endY: 4
                                        )
                                    ]
                                );
                            },
                        )
                    ]
                )
            )
        );
    }
}