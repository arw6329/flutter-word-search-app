// maps normalized words to original word for display
// for example { 'SOUTHKOREA': 'South Korea' }
Map<String, String> normalizeWords(List<String> words, String Function(String) wordNormalizer) {
    return Map.fromEntries(words.map(
        (word) => MapEntry(
            wordNormalizer(word),
            word
        )
    ));
}
