import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';

Future<({String theme, List<String> words})> retrieveWordsAndThemeFromRandomWordlistFile({required String wordlistFolder, required int maxLength, required int minCount, required int maxCount}) async {
    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final wordlists = assetManifest.listAssets().where((string) => string.startsWith('assets/wordlists/$wordlistFolder/'));
    final selectedWordlist = wordlists.shuffled().first;

    final theme = selectedWordlist.replaceAll(RegExp('(?:assets/wordlists/$wordlistFolder/|\\.txt)'), '');
    final words = LineSplitter().convert(await rootBundle.loadString(selectedWordlist))
        .where((word) => word.length <= maxLength).toList();

    if(words.length < minCount) {
        throw Exception('Selected wordlist did not have enough eligible words');
    }

    words.shuffle();

    return (theme: theme, words: words.take(Random().nextInt(min(maxCount, words.length) - minCount + 1) + minCount).toList());
}

Future<List<String>> retrieveWordsFromSingleWordlistFile({required String file, required int minCount, required int maxCount}) async {
    final words = LineSplitter().convert(await rootBundle.loadString('assets/wordlists/$file'));
    
    if(words.length < minCount) {
        throw Exception('Selected wordlist did not have enough eligible words');
    }

    return words.sample(Random().nextInt(min(maxCount, words.length) - minCount + 1) + minCount);
}
