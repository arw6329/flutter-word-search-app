import 'package:flutter/material.dart';
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
                        ElevatedButton(
                            onPressed: () {
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const WordSearchPage())
                                );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Color.fromRGBO(22, 22, 22, 0.7),
                                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 22),
                                textStyle: TextStyle(
                                    fontSize: 20
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)
                                )
                            ),
                            child: Row(
                                children: [
                                    Flexible(
                                        fit: FlexFit.tight,
                                        child: Text('Themed Normal')
                                    ),
                                    Text('12 x 15')
                                ]
                            )
                        ),
                    ],
                ),
            )
        );
    }
}