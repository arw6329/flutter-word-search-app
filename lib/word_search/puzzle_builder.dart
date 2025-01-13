import 'dart:developer';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:word_search_app/util/random.dart';

class WordSearchGenerationException implements Exception {
    String cause;
    WordSearchGenerationException(this.cause);

    @override
    String toString() {
        return cause;
    }
}

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

    Map toJson() => {
        'dx': dx,
        'dy': dy
    };

    factory Direction.fromJson(Map<String, dynamic> jsonObject) {
        return Direction.values.firstWhere((dir) => (dir.dx, dir.dy) == (jsonObject['dx'], jsonObject['dy']));
    }
}

class Placement {
    const Placement({required this.row, required this.column, required this.direction, required this.word});

    final int row;
    final int column;
    final Direction direction;
    final String word;

    @override
    String toString() {
        return '($word at (row $row, col $column) towards (${direction.dy}, ${direction.dx}))';
    }

    bool runsAdjacentTo(Placement other) {
        const lengthLimit = 3;

        bool placementsOverlap(Placement a, Placement b) {
            return a._pointSequence().where((point) => b.containsPoint(point)).length > lengthLimit;
        }

        if (direction case Direction.LEFT || Direction.RIGHT) {
            final above = _shift(-1, 0);
            if(placementsOverlap(above, other)) {
                return true;
            }

            final below = _shift(1, 0);
            if(placementsOverlap(below, other)) {
                return true;
            }
        } else {
            final left = _shift(0, -1);
            if(placementsOverlap(left, other)) {
                return true;
            }

            final right = _shift(0, 1);
            if(placementsOverlap(right, other)) {
                return true;
            }
        }

        return false;
    }

    Placement _shift(int dRow, int dColumn) {
        return Placement(row: row + dRow, column: column + dColumn, direction: direction, word: word);
    }

    bool containsPoint((int row, int column) point) {
        return _pointSequence().contains(point);
    }

    Iterable<(int row, int column)> _pointSequence() sync* {
        for(var i = 0; i < word.length; i++) {
            yield (row + direction.dy * i, column + direction.dx * i);
        }
    }

    Map toJson() => {
        'row': row,
        'column': column,
        'direction': direction,
        'word': word
    };

    factory Placement.fromJson(Map<String, dynamic> jsonObject) {
        return Placement(row: jsonObject['row'], column: jsonObject['column'], direction: Direction.fromJson(jsonObject['direction']), word: jsonObject['word']);
    }
}

enum FillStrategy {
    ALPHABETIC, NUMERIC
}

class PuzzleBuilder {
    PuzzleBuilder({required this.rows, required this.columns, required FillStrategy fillStrategy, required List<String> words}):
        _puzzle = List.generate(rows, (_) => List.generate(columns, (_) => null, growable: false), growable: false),
        placements = [] {
            _buildPuzzle(words, fillStrategy);
        }

    PuzzleBuilder._fromDeserialized({required this.placements, required List<List<int>> puzzle}):
        rows = puzzle.length,
        columns = puzzle[0].length,
        _puzzle = puzzle;

    final int rows;
    final int columns;

    List<Placement> placements;

    final List<List<int?>> _puzzle;

    Map<Direction, int> _getNumberOfPlacementsPerDirection() {
        var map = Map.fromEntries(Direction.values.map((direction) => MapEntry(direction, 0)));

        for(var placement in placements) {
            map[placement.direction] = map[placement.direction]! + 1;
        }

        return map;
    }

    // score of 0 indicates impossible placement
    // the higher the score, the better the placement
    double _scorePlacement(String word, int row, int column, Direction direction) {
        double score = 1;

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

        // reward placements that don't bunch up against existing ones
        var placement = Placement(row: row, column: column, direction: direction, word: word);
        if(placements.every((existingPlacement) => !placement.runsAdjacentTo(existingPlacement))) {
            score += 5;
        }

        // reward placements that use all directions evenly
        var directionCounts = _getNumberOfPlacementsPerDirection();
        directionCounts[direction] = directionCounts[direction]! + 1;
        final maxCount = directionCounts.values.reduce(math.max);
        final avgCount = directionCounts.values.average;
        double distributionScore = (avgCount / maxCount);
        score += distributionScore * 10;

        return score;
    }

    _writePlacement(Placement placement) {
        log('Writing placement $placement');

        for(final (i, charCode) in placement.word.runes.indexed) {
            int _row = placement.row + placement.direction.dy * i;
            int _column = placement.column + placement.direction.dx * i;

            _puzzle[_row][_column] = charCode;
        }

        placements.add(placement);
    }

    _buildPuzzle(List<String> words, FillStrategy fillStrategy) {
        // sort by longest first
        words = words.toList();
        words.sort((a, b) => b.length.compareTo(a.length));

        for(final word in words) {
            Placement? bestPlacement;
            double bestPlacementScore = 0;

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
                throw WordSearchGenerationException('Could not place word $word');
            }

            _writePlacement(bestPlacement);
        }

        for(var row = 0; row < rows; row++) {
            for(var column = 0; column < columns; column++) {
                if(_puzzle[row][column] == null) {
                    _puzzle[row][column] = switch(fillStrategy) {
                        FillStrategy.ALPHABETIC => randomLetter().codeUnitAt(0),
                        FillStrategy.NUMERIC => randomDigitString(1).codeUnitAt(0),
                    };
                }
            }
        }

        if(kDebugMode) {
            for(final placement in placements) {
                for(final otherPlacement in placements) {
                    if(placement.runsAdjacentTo(otherPlacement)) {
                        log('Placements of ${placement.word} and ${otherPlacement.word} are adjacent');
                    }
                }
            }

            log('Number of placements of each direction: ${_getNumberOfPlacementsPerDirection().entries.toList()}');
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

    Map toJson() => {
        'puzzle': _puzzle,
        'placements': placements
    };

    factory PuzzleBuilder.fromJson(Map<String, dynamic> jsonObject) {
        return PuzzleBuilder._fromDeserialized(
            placements: (jsonObject['placements'] as List).map((e) => Placement.fromJson(e)).toList(),
            puzzle: (jsonObject['puzzle'] as List).cast<List>().map((e) => e.cast<int>()).toList()
        );
    }
}