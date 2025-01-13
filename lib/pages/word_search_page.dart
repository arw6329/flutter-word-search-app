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

    Future<WordSearchPageSerializableState?> _retrieveSavedState() async {
        if(!await fileExists('$saveStateDirectory/${gamemode.name}')) {
            return null;
        }
        return WordSearchPageSerializableState.fromJson(
            jsonDecode(await readFile('$saveStateDirectory/${gamemode.name}'))
        );
    }

    Future<void> _saveStateToFile(String title, WordSearchSerializableState internalState) async {
        if(!await directoryExists(saveStateDirectory)) {
            await mkdir(saveStateDirectory);
        }
        await writeFile('$saveStateDirectory/${gamemode.name}', jsonEncode(
            WordSearchPageSerializableState(
                title: title,
                wordSearchState: internalState
            )
        ));
    }

    Future<void> _clearSavedState() async {
        await deleteFile('$saveStateDirectory/${gamemode.name}');
    }

    Future<void> _onSolve(BuildContext context) async {
        (_confettiKey.currentState as ConfettiOverlayState).fire();
        Future.delayed(Duration(milliseconds: 1200)).then((_) {
            if(context.mounted) {
                showSolvedPuzzleDialog(context, gamemode);
            }
        });
        await _clearSavedState();
    }

    @override
    Widget build(BuildContext context) {
        Future<WordSearchPageSerializableState> getSavedOrNewState() async {
            final saveState = await _retrieveSavedState();
            if(saveState != null) {
                return saveState;
            } else {
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
                            title: titleAndWordlist.title,
                            wordSearchState: wordSearchState
                        );
                    } on WordSearchGenerationException catch (exception) {
                        debugPrint('Word search generation failed with error: $exception');
                    }
                }
                throw Exception('Failed to generate puzzle after $maxAttempts attempts');
            }
        }

        return FutureBuilder(
            future: getSavedOrNewState(),
            builder: (BuildContext context, AsyncSnapshot<WordSearchPageSerializableState> snapshot) {
                final title = snapshot.hasData ? (snapshot.data!.title) : '';
                return Stack(
                    children: [
                        Scaffold(
                            appBar: AppBar(
                                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                                title: Text(title),
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
                                        onSolve: () { _onSolve(context); },
                                        onSerializedStateChange: (state) async {
                                            await _saveStateToFile(title, state);
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
    WordSearchPageSerializableState({required this.title, required this.wordSearchState});

    final String title;
    final WordSearchSerializableState wordSearchState;

    Map toJson() => {
        'title': title,
        'wordSearchState': wordSearchState
    };

    factory WordSearchPageSerializableState.fromJson(Map<String, dynamic> jsonObject) {
        return WordSearchPageSerializableState(
            title: jsonObject['title'],
            wordSearchState: WordSearchSerializableState.fromJson(jsonObject['wordSearchState'])
        );
    }
}
