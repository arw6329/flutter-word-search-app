import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:word_search_app/confetti/confetti_overlay.dart';
import 'package:word_search_app/file_writer.dart';
import 'package:word_search_app/gamemodes/gamemode.dart';
import 'package:word_search_app/navigation.dart';
import 'package:word_search_app/pages/home_page.dart';
import 'package:word_search_app/solved_puzzle_dialog.dart';
import 'package:word_search_app/word_search/puzzle_builder.dart';
import 'package:word_search_app/word_search/widgets/word_search.dart';
import 'package:word_search_app/word_search/word_normalizer.dart';

const saveStateDirectory = 'puzzleSaveStates';

class WordSearchPage extends StatelessWidget {
    WordSearchPage({super.key, required this.gamemode});

    final Gamemode gamemode;
    final GlobalKey _wordSearchKey = GlobalKey();
    final GlobalKey _confettiKey = GlobalKey();

    Future<WordSearchPageSerializableState> _getSavedOrNewState() async {
        late final Map<String, dynamic> saveData;
        if(!await fileExists('$saveStateDirectory/${gamemode.name}')) {
            saveData = {
                'index': 1,
                'title': null,
                'wordSearchState': null
            };
        } else {
            saveData = jsonDecode(await readFile('$saveStateDirectory/${gamemode.name}'));
        }

        if(saveData['title'] == null || saveData['wordSearchState'] == null) {
            const maxAttempts = 10;
            for(var attempts = 0; attempts < maxAttempts; attempts++) {
                try {
                    final titleAndWordlist = await gamemode.getNewTitleAndWordlist();
                    final normalizedWords = normalizeWords(titleAndWordlist.words, gamemode.wordNormalizer);

                    final puzzle = PuzzleBuilder(
                        rows: 15,
                        columns: 12,
                        fillStrategy: gamemode.fillStrategy,
                        words: normalizedWords.keys.toList()
                    );

                    final wordSearchState = WordSearchSerializableState.newUnsolved(normalizedWords, puzzle);

                    return WordSearchPageSerializableState(
                        index: saveData['index'],
                        title: titleAndWordlist.title,
                        wordSearchState: wordSearchState
                    );
                } on WordSearchGenerationException catch (exception) {
                    debugPrint('Word search generation failed with error: $exception');
                }
            }
            throw Exception('Failed to generate puzzle after $maxAttempts attempts');
        } else {
            return WordSearchPageSerializableState.fromJson(saveData);
        }
    }

    Future<void> _saveStateToFile(int index, String title, WordSearchSerializableState internalState) async {
        if(!await directoryExists(saveStateDirectory)) {
            await mkdir(saveStateDirectory);
        }
        await writeFile('$saveStateDirectory/${gamemode.name}', jsonEncode(
            WordSearchPageSerializableState(
                index: index,
                title: title,
                wordSearchState: internalState
            )
        ));
    }

    Future<void> _saveIndexOnlyToFile(int index) async {
        await writeFile('$saveStateDirectory/${gamemode.name}', jsonEncode({
            'index': index
        }));
    }

    Future<void> _onSolve(BuildContext context, int nextIndex) async {
        (_confettiKey.currentState as ConfettiOverlayState).fire();
        Future.delayed(Duration(milliseconds: 1200)).then((_) {
            if(context.mounted) {
                showSolvedPuzzleDialog(context, gamemode);
            }
        });
        await _saveIndexOnlyToFile(nextIndex);
    }

    @override
    Widget build(BuildContext context) {
        return FutureBuilder(
            future: _getSavedOrNewState(),
            builder: (BuildContext context, AsyncSnapshot<WordSearchPageSerializableState> snapshot) {
                final title = snapshot.hasData ? snapshot.data!.title : '';
                final index = snapshot.hasData ? snapshot.data!.index : 1;
                return Stack(
                    children: [
                        Scaffold(
                            appBar: AppBar(
                                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                                title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: snapshot.hasData ? [
                                        Text(title),
                                        Container(
                                            margin: EdgeInsets.only(left: 1),
                                            child: Text(
                                                'Puzzle $index',
                                                style: TextStyle(fontSize: 13)
                                            )
                                        )
                                    ] : []
                                ),
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
                                    ? WordSearch(
                                        key: _wordSearchKey,
                                        initialState: snapshot.data!.wordSearchState,
                                        onSolve: () { _onSolve(context, index + 1); },
                                        onSerializedStateChange: (state) async {
                                            await _saveStateToFile(index, title, state);
                                        }
                                    )
                                : snapshot.hasError
                                    ? Text('Error generating puzzle: ${snapshot.error}')
                                    : Text('Loading puzzle')
                            ),
                            floatingActionButton: kDebugMode
                                ? TextButton(onPressed: () { (_wordSearchKey.currentState as WordSearchState).solve(); }, child: Text('Solve puzzle'))
                                : null
                        ),
                        ConfettiOverlay(key: _confettiKey)
                    ]
                );
            }
        ); 
    }
}

class WordSearchPageSerializableState {
    WordSearchPageSerializableState({required this.index, required this.title, required this.wordSearchState});

    final int index;
    final String title;
    final WordSearchSerializableState wordSearchState;

    Map toJson() => {
        'index': index,
        'title': title,
        'wordSearchState': wordSearchState
    };

    factory WordSearchPageSerializableState.fromJson(Map<String, dynamic> jsonObject) {
        return WordSearchPageSerializableState(
            index: jsonObject['index'],
            title: jsonObject['title'],
            wordSearchState: WordSearchSerializableState.fromJson(jsonObject['wordSearchState'])
        );
    }
}
