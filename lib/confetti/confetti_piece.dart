import 'dart:math';

import 'package:flutter/material.dart';
import 'package:word_search_app/confetti/linear_animation.dart';
import 'package:word_search_app/util/vector.dart';

class ConfettiColors {
    static const red = Colors.red;
    static const yellow = Colors.yellow;
    static const green = Colors.green;
    static const blue = Colors.blue;
    static const white = Colors.white;
    static const purple = Colors.purple;
    static const orange = Colors.orange;

    static random() {
        const colors = [red, yellow, green, blue, white, purple, orange];
        return colors[Random().nextInt(colors.length)];
    }
}

class ConfettiPiece extends StatefulWidget {
    const ConfettiPiece({super.key, required this.width, required this.height, required this.startOffset, required this.endOffset, required this.rotationDuration, required this.translationDuration});

    final double width;
    final double height;
    final FractionalOffset startOffset;
    final FractionalOffset endOffset;
    final Duration rotationDuration;
    final Duration translationDuration;

    factory ConfettiPiece.foregroundPiece({Key? key}) {
        const spread = 1;
        final startFractionalOffset = FractionalOffset(Random().nextDouble(), Random().nextDouble() * spread - spread);
        final endFractionalOffset = FractionalOffset(startFractionalOffset.dx, 1 + 0.2 + (spread - startFractionalOffset.dy.abs()));
        return ConfettiPiece(
            key: key,
            width: 10,
            height: 20,
            startOffset: startFractionalOffset,
            endOffset: endFractionalOffset,
            rotationDuration: Duration(seconds: 1),
            translationDuration: Duration(seconds: 5)
        );
    }

    factory ConfettiPiece.backgroundPiece({Key? key}) {
        final startFractionalOffset = FractionalOffset(0.5, 0.5);
        final locationVector = randomPositiveVector2Normalized() * sqrt2 * (1 + Random().nextDouble() * 2) * 0.5;
        final locationTargetOffset = Offset(locationVector.x * positiveOrNegative(), - locationVector.y);
        final endFractionalOffset = FractionalOffset(startFractionalOffset.dx + locationTargetOffset.dx, startFractionalOffset.dy + locationTargetOffset.dy);
        return ConfettiPiece(
            key: key,
            width: 5,
            height: 10,
            startOffset: startFractionalOffset,
            endOffset: endFractionalOffset,
            rotationDuration: Duration(milliseconds: 600),
            translationDuration: Duration(milliseconds: 800)
        );
    }

    @override
    State<ConfettiPiece> createState() => _ConfettiPieceState();
}

// TODO: make Single if possible
class _ConfettiPieceState extends State<ConfettiPiece> with TickerProviderStateMixin {
    late AnimationController _rotationController;
    late AnimationController _locationController;
    double _rotation = 0;
    late FractionalOffset _fractionalOffset;
    final _randomRotationAxis = randomVector3Normalized();
    final _initialRotation = Random().nextDouble() * 2 * pi;
    final Color _color = ConfettiColors.random();

    @override
    void initState() {
        super.initState();

        _fractionalOffset = widget.startOffset;

        _rotationController = startLinearAnimation<double>(
            provider: this,
            duration: widget.rotationDuration,
            callback: (rotation) {
                if(mounted) {
                    setState(() {
                        _rotation = rotation;
                    });
                }
            },
            start: 0,
            end: 2 * pi,
            repeat: true
        );

        _locationController = startLinearAnimation<FractionalOffset>(
            provider: this,
            duration: widget.translationDuration,
            callback: (offset) {
                if(mounted) {
                    setState(() {
                        _fractionalOffset = offset;
                    });
                }
            },
            start: widget.startOffset,
            end: widget.endOffset
        );
    }

    @override
    Widget build(BuildContext context) {
        return Container(
            alignment: _fractionalOffset,
            child: Transform(
                transform: Matrix4.rotationX(_initialRotation)..rotate(_randomRotationAxis, _rotation),
                origin: Offset(widget.width / 2, widget.height / 2),
                child: Container(
                    width: widget.width,
                    height: widget.height,
                    decoration: BoxDecoration(
                        color: _color
                    )
                )
            )
        );
    }

    @override
    void dispose() {
        _rotationController.dispose();
        _locationController.dispose();
        super.dispose();
    }
}