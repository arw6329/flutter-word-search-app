import 'package:word_search_app/gamemodes/gamemode.dart';
import 'package:word_search_app/util/random.dart';
import 'package:word_search_app/word_search/puzzle_builder.dart';

// for debugging error handling only
class ImpossibleToGenerateGamemode implements Gamemode {
    const ImpossibleToGenerateGamemode(): super();
    
    @override
    final String name = 'ImpossibleToGenerate';

    @override
    final FillStrategy fillStrategy = FillStrategy.NUMERIC;

    @override
    Future<({String title, List<String> words})> getNewTitleAndWordlist() async {
        return (title: 'Buggy', words: [
            for(var i = 0; i < 50; i++) randomDigitString(20)
        ]);
    }
    
    @override
    String wordNormalizer(String word) {
        return word.toUpperCase().replaceAll(RegExp('[^0-9]'), '');
    }
}
