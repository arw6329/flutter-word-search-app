import 'package:word_search_app/util/randomized_range.dart';

enum Direction {
    LEFT(-1, 0), RIGHT(1, 0), UP(0, -1), DOWN(0, 1), LEFT_UP(-1, -1), LEFT_DOWN(-1, 1), RIGHT_UP(1, -1), RIGHT_DOWN(1, 1);

    const Direction(this.dx, this.dy);

    final int dx;
    final int dy;
}

class Placement {
    const Placement({required this.score, required this.row, required this.column, required this.direction, required this.word});

    final int score;
    final int row;
    final int column;
    final Direction direction;
    final String word;
}

class PuzzleBuilder {
    PuzzleBuilder({required this.rows, required this.columns, required words}):
        _puzzle = List.generate(rows, (_) => List.generate(columns, (_) => null, growable: false), growable: false),
        placements = [] {
            _buildPuzzle(words);
        }

    final int rows;
    final int columns;

    List<Placement> placements;

    final List<List<int?>> _puzzle;

    // score of 0 indicates impossible placement
    // the higher the score, the better the placement
    _scorePlacement(String word, int row, int column, Direction direction) {
        var score = 1;

        for(final (i, charCode) in word.runes.indexed) {
            int _row = row + direction.dx * i;
            int _column = column + direction.dy * i;

            // skip if placement goes out of bounds of puzzle
            if(_row < 0 || _row >= rows || _column < 0 || _column >= columns) {
                return 0;
            }

            // skip if word overlaps an existing word incorrectly
            if(_puzzle[_row][_column] != null && _puzzle[_row][_column] != charCode) {
                return 0;
            }

            // reward valid overlaps
            if(_puzzle[_row][_column] != null) {
                score += 1;
            }
        }

        return score;
    }

    _writePlacement(Placement placement) {
        for(final (i, charCode) in placement.word.runes.indexed) {
            int _row = placement.row + placement.direction.dx * i;
            int _column = placement.column + placement.direction.dy * i;

            _puzzle[_row][_column] = charCode;
        }

        placements.add(placement);
    }

    _buildPuzzle(List<String> words) {
        words = words.map((word) => word.toUpperCase()).toList();
        // sort by longest first
        words.sort((a, b) => b.length.compareTo(a.length));

        for(final word in words) {
            Placement? bestPlacement;

            for(final row in randomizedRange(0, rows - 1)) {
                for(final column in randomizedRange(0, columns - 1)) {
                    for(final direction in Direction.values) {
                        final newPlacementScore = _scorePlacement(word, row, column, direction);

                        if(bestPlacement == null || newPlacementScore > bestPlacement.score) {
                            bestPlacement = Placement(score: newPlacementScore, row: row, column: column, direction: direction, word: word);
                        }
                    }
                }
            }

            if(bestPlacement == null || bestPlacement.score == 0) {
                throw Exception('Could not place word $word');
            }

            _writePlacement(bestPlacement);
        }
    }

    charAt(int row, int column) {
        final charCode = _puzzle[row][column];
        return charCode != null ? String.fromCharCode(charCode) : null;
    }
}