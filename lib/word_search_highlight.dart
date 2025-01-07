import 'dart:math';

import 'package:flutter/material.dart';

class WordSearchHighlight extends StatelessWidget {
    const WordSearchHighlight({
        super.key,
        required this.puzzleRows,
        required this.puzzleColumns,
        required this.constraints,
        required this.startX,
        required this.startY,
        required this.endX,
        required this.endY,
    });

    final BoxConstraints constraints;
    final int puzzleRows;
    final int puzzleColumns;
    final int startX;
    final int startY;
    final int endX;
    final int endY;
    
    @override
    Widget build(BuildContext context) {
        var cellSize = constraints.maxWidth / puzzleColumns;
        var left = min(cellSize * startX, cellSize * endX);
        var top = min(cellSize * startY, cellSize * endY);

        var isDiagonal = startX != endX && startY != endY;
        var isDiagBackslash = isDiagonal && (endX - startX).isNegative == (endY - startY).isNegative;
        var isDiagForwardSlash = isDiagonal && (endX - startX).isNegative != (endY - startY).isNegative;

        return Container(
            margin: EdgeInsets.fromLTRB(left, top, 0, 0),
            child: ClipPath(
                clipper: isDiagBackslash
                            ? BackslashDiagClipper(cellSize: cellSize)
                        : isDiagForwardSlash
                            ? ForwardSlashDiagClipper(cellSize: cellSize)
                            : null,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: isDiagonal ? null : BorderRadius.circular(cellSize / 2),
                        color: Colors.orange
                    ),
                    width: cellSize * ((endX - startX).abs() + 1),
                    height: cellSize * ((endY - startY).abs() + 1),
                )
            )
        );
    }
}

class BackslashDiagClipper extends CustomClipper<Path> {
    const BackslashDiagClipper({required this.cellSize});

    final double cellSize;

    @override
    Path getClip(Size size) {
        var roundedEndRadius = cellSize / 2;
        var centerUpperLeftCell = Offset(size.width - roundedEndRadius, size.height - roundedEndRadius);
        var centerLowerRightCell = Offset(roundedEndRadius, roundedEndRadius);

        var path = Path();

        path.addArc(Rect.fromCircle(center: centerUpperLeftCell, radius: roundedEndRadius), - pi / 4, pi);
        path.addArc(Rect.fromCircle(center: centerLowerRightCell, radius: roundedEndRadius), pi * 0.75, pi);
        path.lineTo(centerUpperLeftCell.dx + roundedEndRadius / sqrt2, centerUpperLeftCell.dy - roundedEndRadius / sqrt2);
        path.lineTo(centerUpperLeftCell.dx - roundedEndRadius / sqrt2, centerUpperLeftCell.dy + roundedEndRadius / sqrt2);
        path.close();

        return path;
    }

    @override
    bool shouldReclip(CustomClipper<Path> oldClipper) {
        return false;
    }
}

class ForwardSlashDiagClipper extends CustomClipper<Path> {
    const ForwardSlashDiagClipper({required this.cellSize});

    final double cellSize;

    @override
    Path getClip(Size size) {
        var roundedEndRadius = cellSize / 2;
        var centerLowerLeftCell = Offset(roundedEndRadius, size.height - roundedEndRadius);
        var centerUpperRightCell = Offset(size.width - roundedEndRadius, roundedEndRadius);

        var path = Path();

        path.addArc(Rect.fromCircle(center: centerLowerLeftCell, radius: roundedEndRadius), pi / 4, pi);
        path.addArc(Rect.fromCircle(center: centerUpperRightCell, radius: roundedEndRadius), pi * 1.25, pi);
        path.lineTo(centerLowerLeftCell.dx + roundedEndRadius / sqrt2, centerLowerLeftCell.dy + roundedEndRadius / sqrt2);
        path.lineTo(centerLowerLeftCell.dx - roundedEndRadius / sqrt2, centerLowerLeftCell.dy - roundedEndRadius / sqrt2);
        path.close();

        return path;
    }

    @override
    bool shouldReclip(CustomClipper<Path> oldClipper) {
        return false;
    }
}