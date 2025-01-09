import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';

Future<List<String>> retrieveRandomWordlist(int count) async {
    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final wordlists = assetManifest.listAssets().where((string) => string.startsWith('assets/wordlists/'));
    final wordlist = LineSplitter().convert(await rootBundle.loadString(wordlists.shuffled().first));
    wordlist.shuffle();
    return wordlist.take(count).toList();
}