/// Utility class for string normalization and comparison operations
class StringUtils {
  /// Normalizes a string by:
  /// 1. Trimming leading/trailing whitespace
  /// 2. Converting to lowercase
  /// 3. Replacing multiple spaces with single space
  /// 4. Removing extra punctuation (preserving & for job types)
  static String normalize(String value) {
    if (value.isEmpty) return value;

    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(
          RegExp(r'[^\w\s&]'),
          '',
        ); // Remove special characters except word, space, and &
  }

  /// Compares two strings after normalization
  static bool equalsNormalized(String a, String b) {
    return normalize(a) == normalize(b);
  }

  /// Checks if a string contains another string after normalization
  static bool containsNormalized(String haystack, String needle) {
    String normalizedHaystack = normalizeAndFix(haystack);
    String normalizedNeedle = normalizeAndFix(needle);
    return normalizedHaystack.contains(normalizedNeedle);
  }

  /// Fixes common spelling mistakes in job types
  static String fixCommonMistakes(String value) {
    String normalizedValue = normalize(value);

    // Map common typos to correct values
    const typoMap = {
      'walfare': 'welfare',
      'welffare': 'welfare',
      'communitiy': 'community',
      'commmunity': 'community',
      'maszid': 'masjid',
      'madressa': 'madrasa',
      'madrasah': 'madrasa',
      'educationalinstitute': 'educational institute',
      'shopandbusiness': 'shops & business',
      'shopsbusiness': 'shops & business',
      // Handle common compound mistakes
      'community walfare': 'community welfare',
      'community & walfare': 'community & welfare',
      'community welffare': 'community welfare',
      'masjid madrasa': 'masjid & madrasa',
      'masjid & madressa': 'masjid & madrasa',
      'masjid madressa': 'masjid & madrasa',
      'educational instutute': 'educational institute',
      'educational institue': 'educational institute',
      // Variants with different spacing
      'community&walfare': 'community & welfare',
      'community& walfare': 'community & welfare',
      'community &walfare': 'community & welfare',
    };

    // Check for exact match first
    if (typoMap.containsKey(normalizedValue)) {
      return typoMap[normalizedValue]!;
    }

    // If no exact match, return original value
    return value;
  }

  /// Normalizes and fixes common mistakes in one go
  static String normalizeAndFix(String value) {
    return normalize(fixCommonMistakes(value));
  }
}
