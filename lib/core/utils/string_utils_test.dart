import 'string_utils.dart';

void main() {
  // Test basic normalization
  print('Testing normalization:');
  print(
    "Original: ' Masjid & Madrasa ' -> Normalized: '${StringUtils.normalize(' Masjid & Madrasa ')}'",
  );
  print(
    "Original: 'MASJID & MADRASA' -> Normalized: '${StringUtils.normalize('MASJID & MADRASA')}'",
  );
  print(
    "Original: 'masjid  &  madrasa' -> Normalized: '${StringUtils.normalize('masjid  &  madrasa')}'",
  );

  // Test typo fixing
  print('\nTesting typo fixing:');
  print(
    "Original: 'walfare' -> Fixed: '${StringUtils.fixCommonMistakes('walfare')}'",
  );
  print(
    "Original: 'communitiy' -> Fixed: '${StringUtils.fixCommonMistakes('communitiy')}'",
  );
  print(
    "Original: 'educationalinstitute' -> Fixed: '${StringUtils.fixCommonMistakes('educationalinstitute')}'",
  );

  // Test the specific issue case
  print('\nTesting the specific issue case:');
  print(
    "Original: 'Community & Walfare' -> Normalized: '${StringUtils.normalize('Community & Walfare')}'",
  );
  print(
    "Original: 'Community & Walfare' -> Fixed: '${StringUtils.fixCommonMistakes('Community & Walfare')}'",
  );
  print(
    "Original: 'Community & Walfare' -> NormalizedAndFixed: '${StringUtils.normalizeAndFix('Community & Walfare')}'",
  );
  print(
    "Original: 'community & walfare' -> NormalizedAndFixed: '${StringUtils.normalizeAndFix('community & walfare')}'",
  );
  print(
    "Original: 'Community & Welfare' -> NormalizedAndFixed: '${StringUtils.normalizeAndFix('Community & Welfare')}'",
  );

  // Test string comparison
  print('\nTesting string comparison:');
  print(
    "Compare 'Community & Welfare' with 'Community & Walfare': ${StringUtils.equalsNormalized('Community & Welfare', 'Community & Walfare')}",
  );
  print(
    "Compare 'Community & Welfare' with 'community & welfare': ${StringUtils.equalsNormalized('Community & Welfare', 'community & welfare')}",
  );

  // Test contains functionality
  print('\nTesting contains functionality:');
  print(
    "Contains 'welfare' in 'Community & Welfare': ${StringUtils.containsNormalized('Community & Welfare', 'welfare')}",
  );
  print(
    "Contains 'welfare' in 'Community & Walfare': ${StringUtils.containsNormalized('Community & Walfare', 'welfare')}",
  );
}
