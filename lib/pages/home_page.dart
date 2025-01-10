import 'package:flutter/material.dart';
import 'package:word_search_app/large_common_button.dart';
import 'package:word_search_app/pages/word_search_page.dart';

class HomePage extends StatelessWidget {
    const HomePage({super.key});

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Container(
                margin: EdgeInsets.all(40),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    spacing: 5,
                    children: [
                        Text('Gamemodes', style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                        )),
                        LargeCommonButton(
                            onPressed: () {
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const WordSearchPage())
                                );
                            },
                            child: Row(
                                children: [
                                    Flexible(
                                        fit: FlexFit.tight,
                                        child: Text('Themed Normal')
                                    ),
                                    Text('12 x 15')
                                ]
                            )
                        )
                    ]
                )
            )
        );
    }
}