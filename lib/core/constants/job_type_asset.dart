class JobTypeAsset {
  static const Map<String, String> _iconMap = {
    'masjid & madrasa': 'assets/masjid1.png',
    'educational institute': 'assets/education.png',
    'community & walfare': 'assets/charity.png',
    'shops & business': 'assets/shop.png',
    'other': 'assets/other.png',
  };

  static String getIcon(String jobType) {
    final key = jobType.trim().toLowerCase();
    return _iconMap[key] ?? 'assets/other.png';
  }
}
