import 'package:word_search_app/word_search/puzzle_builder.dart';

abstract class Gamemode {
    const Gamemode();
    
    abstract final String name;
    abstract final FillStrategy fillStrategy;
    Future<({String title, List<String> words})> getNewTitleAndWordlist();
    String wordNormalizer(String word);
}
