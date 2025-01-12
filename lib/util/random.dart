import 'dart:math';

List<int> randomizedRange(int start, int end) {
    final range = List<int>.generate(end - start + 1, (i) => i + start, growable: false);
    range.shuffle();
    return range;
}

String randomLetter() {
    final charCodes = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.runes.toList();
    return String.fromCharCode(charCodes[Random().nextInt(charCodes.length)]);
}

String randomDigitString(int length) {
    final random = Random();
    return [
        for(var i = 0; i < length; i++) random.nextInt(10)
    ].join('');
}