import 'dart:math';

randomizedRange(int start, int end) {
    final range = List<int>.generate(end - start + 1, (i) => i + start, growable: false);
    range.shuffle();
    return range;
}

randomLetter() {
    final charCodes = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.runes.toList();
    return String.fromCharCode(charCodes[Random().nextInt(charCodes.length)]);
}
