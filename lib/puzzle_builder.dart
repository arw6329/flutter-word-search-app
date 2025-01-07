import 'package:word_search_app/util/random.dart';

enum Direction {
    LEFT(-1, 0), RIGHT(1, 0), UP(0, -1), DOWN(0, 1), LEFT_UP(-1, -1), LEFT_DOWN(-1, 1), RIGHT_UP(1, -1), RIGHT_DOWN(1, 1);

    const Direction(this.dx, this.dy);

    final int dx;
    final int dy;

    static Direction fromStartAndEndPoints(int startX, int startY, int endX, int endY) {
        final dx = endX - startX;
        final dy = endY - startY;
        if((dx != 0 && dy != 0) && dx.abs() != dy.abs()) {
            throw Exception('Direction from ($startX,$startY) to ($endX,$endY) is not valid because it is not horizontal, vertical, or diagonal at 45 degrees');
        }

        switch((dx.clamp(-1, 1), dy.clamp(-1, 1))) {
            case (0, 0):
            case (-1, 0): {
                return Direction.LEFT;
            }
            case (1, 0): {
                return Direction.RIGHT;
            }
            case (0, -1): {
                return Direction.UP;
            }
            case (0, 1): {
                return Direction.DOWN;
            }
            case (-1, -1): {
                return Direction.LEFT_UP;
            }
            case (-1, 1): {
                return Direction.LEFT_DOWN;
            }
            case (1, -1): {
                return Direction.RIGHT_UP;
            }
            case (1, 1): {
                return Direction.RIGHT_DOWN;
            }
            default: {
                throw Exception('Not possible');
            }
        }
    }
}

class Placement {
    const Placement({required this.row, required this.column, required this.direction, required this.word});

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
            int _row = row + direction.dy * i;
            int _column = column + direction.dx * i;

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
            int _row = placement.row + placement.direction.dy * i;
            int _column = placement.column + placement.direction.dx * i;

            _puzzle[_row][_column] = charCode;
        }

        placements.add(placement);
    }

    _buildPuzzle(List<String> words) {
        // sort by longest first
        words = words.toList();
        words.sort((a, b) => b.length.compareTo(a.length));

        for(final word in words) {
            Placement? bestPlacement;
            int bestPlacementScore = 0;

            for(final row in randomizedRange(0, rows - 1)) {
                for(final column in randomizedRange(0, columns - 1)) {
                    for(final direction in Direction.values) {
                        final newPlacementScore = _scorePlacement(word, row, column, direction);

                        if(bestPlacement == null || newPlacementScore > bestPlacementScore) {
                            bestPlacement = Placement(row: row, column: column, direction: direction, word: word);
                            bestPlacementScore = newPlacementScore;
                        }
                    }
                }
            }

            if(bestPlacement == null || bestPlacementScore == 0) {
                throw Exception('Could not place word $word');
            }

            _writePlacement(bestPlacement);
        }

        for(var row = 0; row < rows; row++) {
            for(var column = 0; column < columns; column++) {
                if(_puzzle[row][column] == null) {
                    _puzzle[row][column] = randomLetter().codeUnitAt(0);
                }
            }
        }
    }

    charAt(int row, int column) {
        return String.fromCharCode(_puzzle[row][column]!);
    }

    String sequenceAt(int startX, int startY, Direction direction, int length) {
        var sequence = '';
        
        for(var i = 0; i < length; i++) {
            sequence += String.fromCharCode(_puzzle[startY + direction.dy * i][startX + direction.dx * i]!);
        }

        return sequence;
    }
}