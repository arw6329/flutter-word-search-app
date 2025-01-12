import 'package:flutter/material.dart';
import 'package:word_search_app/confetti/confetti_piece.dart';

class ConfettiOverlay extends StatefulWidget {
    const ConfettiOverlay({super.key});

    static const confettiCountForeground = 60;
    static const confettiCountBackground = 100;

    @override
    State<ConfettiOverlay> createState() => ConfettiOverlayState();
}

class ConfettiOverlayState extends State<ConfettiOverlay> {
    bool _fired = false;

    fire() {
        if(!_fired) {
            setState(() {
                _fired = true;
            });
        }
    }

    @override
    Widget build(BuildContext context) {
        return _fired ? Stack(
            children: [
                FutureBuilder(
                    future: Future.delayed(Duration(milliseconds: 650), () => 1),
                    builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                        if(snapshot.hasData) {
                            return Stack(
                                children: [
                                    for(var i = 0; i < ConfettiOverlay.confettiCountForeground; i++) ConfettiPiece.foregroundPiece()
                                ]
                            );
                        } else {
                            return Container();
                        }
                    }
                ),
                for(var i = 0; i < ConfettiOverlay.confettiCountBackground; i++) ConfettiPiece.backgroundPiece()
            ]
        ) : Container();
    }
}