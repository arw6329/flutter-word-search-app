import 'package:flutter/material.dart';
import 'package:word_search_app/word_search/widgets/word_search.dart';
import 'package:word_search_app/word_search/wordlist_retrieval.dart';

void main() {
    runApp(const MyApp());
}
class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.deepPurple,
                    brightness: Brightness.dark
                ),
                useMaterial3: true,
            ),
            home: const MyHomePage(title: 'Flutter Demo Home Page'),
        );
    }
}
class MyHomePage extends StatelessWidget {
    const MyHomePage({super.key, required this.title});

    final String title;

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: Text(title),
            ),
            body: FutureBuilder(
                future: retrieveRandomWordlist(20),
                builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                    return Center(
                        child: snapshot.hasData
                            ? WordSearch(rows: 15, columns: 12, words: snapshot.data!)
                        : snapshot.hasError
                            ? Text('Error generating puzzle: ${snapshot.error}')
                            : Text('Loading puzzle')
                    );
                }
            )
        );
    }
}
