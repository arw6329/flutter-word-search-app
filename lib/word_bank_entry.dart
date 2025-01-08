import 'package:flutter/material.dart';

class WordBankEntry extends StatelessWidget {
    const WordBankEntry({super.key, required this.word, required this.solved});

    final String word;
    final bool solved;

    @override
    Widget build(BuildContext context) {
        return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Center(
                    child: AnimatedDefaultTextStyle(
                        style: solved
                            ? TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Color.fromARGB(255, 110, 110, 110),
                                decoration: TextDecoration.lineThrough
                            )
                            : TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                            ),
                        duration: Duration(milliseconds: 500),
                        child: Text(word)
                    )
                )
            ]
        );
    }
}
