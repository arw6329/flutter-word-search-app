abstract class Gamemode {
    const Gamemode();
    
    abstract final String name;
    Future<({String title, List<String> words})> getNewTitleAndWordlist();
}
