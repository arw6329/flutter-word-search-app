import 'package:word_search_app/gamemodes/gamemode.dart';
import 'package:word_search_app/word_search/puzzle_builder.dart';
import 'package:word_search_app/word_search/wordlist_retrieval.dart';

class RandomNormalGamemode implements Gamemode {
    const RandomNormalGamemode(): super();
    
    @override
    final String name = 'RandomNormal';

    @override
    final FillStrategy fillStrategy = FillStrategy.ALPHABETIC;

    @override
    Future<({String title, List<String> words})> getNewTitleAndWordlist() async {
        final wordlist = await retrieveWordsFromSingleWordlistFile(
            file: '$name.txt',
            minCount: 18,
            maxCount: 20
        );
        return (title: 'Random Words', words: wordlist);
    }

    @override
    String wordNormalizer(String word) {
        return word.toUpperCase().replaceAll(RegExp('[^A-Z]'), '');
    }
}