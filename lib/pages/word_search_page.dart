import 'package:flutter/material.dart';
import 'package:word_search_app/word_search/widgets/word_search.dart';
import 'package:word_search_app/word_search/wordlist_retrieval.dart';

class WordSearchPage extends StatelessWidget {
    const WordSearchPage({super.key});

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
                        automaticallyImplyLeading: false
                    ),
                    body: Center(
                        child: snapshot.hasData
                            ? WordSearch(rows: 15, columns: 12, words: snapshot.data!.$2)
                        : snapshot.hasError
                            ? Text('Error generating puzzle: ${snapshot.error}')
                            : Text('Loading puzzle')
                    )
                );
            }
        ); 
    }
}
