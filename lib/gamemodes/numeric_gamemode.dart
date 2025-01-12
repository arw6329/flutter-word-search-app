import 'package:word_search_app/gamemodes/gamemode.dart';
import 'package:word_search_app/util/random.dart';
import 'package:word_search_app/word_search/puzzle_builder.dart';

class NumericGamemode implements Gamemode {
    const NumericGamemode(): super();
    
    @override
    final String name = 'Numeric';

    @override
    final FillStrategy fillStrategy = FillStrategy.NUMERIC;

    @override
    Future<({String title, List<String> words})> getNewTitleAndWordlist() async {
        return (title: 'Numeric', words: [
            for(var i = 0; i < 20; i++) randomDigitString(6)
        ]);
    }
    
    @override
    String wordNormalizer(String word) {
        return word.toUpperCase().replaceAll(RegExp('[^0-9]'), '');
    }
}