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
        var isHorizontal = startY == endY;
        var isVertical = startX == endX;

        const hlWidthAsPercentageOfCell = 0.7;
        final spaceBetweenHlAndCellBounds = (cellSize - (cellSize * hlWidthAsPercentageOfCell)) / 2;

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
                    margin: EdgeInsets.all(spaceBetweenHlAndCellBounds),
                    width: isVertical ? cellSize * hlWidthAsPercentageOfCell : cellSize * ((endX - startX).abs() + 1) - spaceBetweenHlAndCellBounds * 2,
                    height: isHorizontal ? cellSize * hlWidthAsPercentageOfCell : cellSize * ((endY - startY).abs() + 1) - spaceBetweenHlAndCellBounds * 2,
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
        var roundedEndRadius = cellSize / 2.85;
        var centerLowerRightCell = Offset(size.width - cellSize / 2, size.height - cellSize / 2);
        var centerUpperLeftCell = Offset(cellSize / 2, cellSize / 2);

        var path = Path();

        path.addArc(Rect.fromCircle(center: centerLowerRightCell, radius: roundedEndRadius), - pi / 4, pi);
        path.addArc(Rect.fromCircle(center: centerUpperLeftCell, radius: roundedEndRadius), pi * 0.75, pi);
        path.lineTo(centerLowerRightCell.dx + roundedEndRadius / sqrt2, centerLowerRightCell.dy - roundedEndRadius / sqrt2);
        path.lineTo(centerLowerRightCell.dx - roundedEndRadius / sqrt2, centerLowerRightCell.dy + roundedEndRadius / sqrt2);
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
        var roundedEndRadius = cellSize / 2.85;
        var centerLowerLeftCell = Offset(cellSize / 2, size.height - cellSize / 2);
        var centerUpperRightCell = Offset(size.width - cellSize / 2, cellSize / 2);

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