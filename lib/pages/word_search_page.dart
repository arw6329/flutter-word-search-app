import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:word_search_app/file_writer.dart';
import 'package:word_search_app/gamemodes/gamemode.dart';
import 'package:word_search_app/navigation.dart';
import 'package:word_search_app/pages/home_page.dart';
import 'package:word_search_app/solved_puzzle_dialog.dart';
import 'package:word_search_app/word_search/widgets/word_search.dart';

const saveStateDirectory = 'puzzleSaveStates';

typedef SaveStateOrNewWordList = ({WordSearchPageSerializableState? saveState, ({String title, List<String> words})? wordlist});

class WordSearchPage extends StatelessWidget {
    const WordSearchPage({super.key, required this.gamemode});

    final Gamemode gamemode;

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

    @override
    Widget build(BuildContext context) {
        Future<SaveStateOrNewWordList>
        savedStateOrNewWordlistFuture() async {
            final saveState = await _retrieveSavedState();
            if(saveState != null) {
                return (saveState: saveState, wordlist: null);
            } else {
                return (saveState: null, wordlist: await gamemode.getNewTitleAndWordlist());
            }
        }

        return FutureBuilder(
            future: savedStateOrNewWordlistFuture(),
            builder: (BuildContext context, AsyncSnapshot<SaveStateOrNewWordList> snapshot) {
                final title = snapshot.hasData ? (snapshot.data!.saveState?.title ?? snapshot.data!.wordlist!.title) : '';
                return Scaffold(
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
                            ? snapshot.data!.saveState != null
                                ? WordSearch.fromSerializedState(
                                    state: snapshot.data!.saveState!.wordSearchState,
                                    onSolve: () {
                                        showSolvedPuzzleDialog(context, gamemode);
                                    },
                                    onSerializedStateChange: (state) async {
                                        await _saveStateToFile(title, state);
                                    }
                                )
                                : WordSearch(
                                    rows: 15,
                                    columns: 12,
                                    words: snapshot.data!.wordlist!.words,
                                    onSolve: () {
                                        showSolvedPuzzleDialog(context, gamemode);
                                    },
                                    onSerializedStateChange: (state) async {
                                        await _saveStateToFile(title, state);
                                    }
                                )
                        : snapshot.hasError
                            ? Text('Error generating puzzle: ${snapshot.error}')
                            : Text('Loading puzzle')
                    )
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