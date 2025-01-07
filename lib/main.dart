import 'package:flutter/material.dart';
import 'package:word_search_app/word_search_puzzle.dart';

const words = [
    'Brazil',
    'Japan',
    'Egypt',
    'Canada',
    'Germany',
    'Kenya',
    'Argentina',
    'India',
    'Australia',
    'Iceland',
    'Thailand',
    'Morocco',
    'Norway',
    'Peru',
    'South Korea',
    'Nigeria',
    'Italy',
    'Chile',
    'Vietnam',
    'Turkey'
];

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
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        WordSearchPuzzle(rows: 15, columns: 12, words: words)
                    ],
                ),
            )
        );
    }
}
