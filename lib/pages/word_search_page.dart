import 'package:flutter/material.dart';
import 'package:word_search_app/large_common_button.dart';
import 'package:word_search_app/navigation.dart';
import 'package:word_search_app/pages/home_page.dart';
import 'package:word_search_app/word_search/widgets/word_search.dart';
import 'package:word_search_app/word_search/wordlist_retrieval.dart';

class WordSearchPage extends StatelessWidget {
    const WordSearchPage({super.key});

    Future<void> _showSolvedPuzzleDialog(BuildContext context) {
        return showDialog(
            context: context,
            builder: (BuildContext context) {
                return SimpleDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    contentPadding: EdgeInsets.all(10),
                    titlePadding: EdgeInsets.all(15) + EdgeInsets.only(bottom: 10),
                    title: Text('Puzzle Completed',
                        textAlign: TextAlign.center,
                    ),
                    children: [
                        Column(
                            spacing: 6,
                            children: [
                                LargeCommonButton(
                                    onPressed: () {
                                        clearHistoryAndNavigateToPage(context, const WordSearchPage());
                                    },
                                    child: Row(
                                        children: [
                                            Flexible(
                                                child: Text('Next Puzzle')
                                            )
                                        ]
                                    )
                                ),
                                LargeCommonButton(
                                    onPressed: () {
                                        clearHistoryAndNavigateToPage(context, const HomePage());
                                    },
                                    color: Color(0xFFAAAAAA),
                                    solid: false,
                                    child: Row(
                                        children: [
                                            Flexible(
                                                child: Text('Home')
                                            )
                                        ]
                                    )
                                )
                            ]
                        )
                    ]
                );
            }
        );
    }

    @override
    Widget build(BuildContext context) {
        final wordlistFuture = retrieveRandomWordlist(20);
        return FutureBuilder(
            future: wordlistFuture,
            builder: (BuildContext context, AsyncSnapshot<(String theme, List<String> words)> snapshot) {
                return Scaffold(
                    appBar: AppBar(
                        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                        title: Text(snapshot.hasData ? snapshot.data!.$1 : ''),
                        automaticallyImplyLeading: false,
                        actions: [
                            IconButton(
                                onPressed: () {
                                    clearHistoryAndNavigateToPage(context, const HomePage());
                                },
                                tooltip: 'Go home', 
                                icon: const Icon(Icons.home)
                            )
                        ]
                    ),
                    body: Center(
                        child: snapshot.hasData
                            ? WordSearch(rows: 15, columns: 12, words: snapshot.data!.$2, onSolve: () {
                                _showSolvedPuzzleDialog(context);
                            })
                        : snapshot.hasError
                            ? Text('Error generating puzzle: ${snapshot.error}')
                            : Text('Loading puzzle')
                    )
                );
            }
        ); 
    }
}
