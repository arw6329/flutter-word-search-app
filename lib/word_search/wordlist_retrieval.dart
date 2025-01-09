import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';

Future<(String theme, List<String> words)> retrieveRandomWordlist(int count) async {
    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final wordlists = assetManifest.listAssets().where((string) => string.startsWith('assets/wordlists/'));
    final selectedWordlist = wordlists.shuffled().first;

    final theme = selectedWordlist.replaceAll(RegExp('(?:assets/wordlists/|\\.txt)'), '');
    final words = LineSplitter().convert(await rootBundle.loadString(selectedWordlist));
    words.shuffle();

    return (theme, words.take(count).toList());
}