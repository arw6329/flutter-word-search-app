import 'package:flutter/material.dart';
import 'package:word_search_app/word_search/widgets/word_bank_entry.dart';

class WordBank extends StatelessWidget {
    const WordBank({super.key, required this.words, required this.solvedWords});

    final Map<String, String> words;
    final Set<String> solvedWords;

    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                Container(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    width: 130 * 3,
                    padding: EdgeInsets.all(4),
                    child: GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        childAspectRatio: 4,
                        children: words.entries.map<WordBankEntry>(
                            (entry) => WordBankEntry(
                                word: entry.value,
                                solved: solvedWords.contains(entry.key)
                            )
                        ).toList(),
                    )
                )
            ]
        );
    }
}