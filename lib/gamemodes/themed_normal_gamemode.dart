import 'package:word_search_app/gamemodes/gamemode.dart';
import 'package:word_search_app/word_search/wordlist_retrieval.dart';

class ThemedNormalGamemode implements Gamemode {
    const ThemedNormalGamemode(): super();
    
    @override
    Future<({String title, List<String> words})> getNewTitleAndWordlist() async {
        final wordlist = await retrieveRandomWordlist(
            wordlistFolder: name,
            maxLength: 11,
            minCount: 16,
            maxCount: 20
        );
        return (title: wordlist.theme, words: wordlist.words);
    }

    @override
    final String name = 'ThemedNormal';
}