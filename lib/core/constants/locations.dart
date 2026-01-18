class LocationConstants {
  static const Map<String, List<String>> statesAndDistricts = {
    'Kerala': [
      'Alappuzha',
      'Ernakulam',
      'Idukki',
      'Kannur',
      'Kasaragod',
      'Kollam',
      'Kottayam',
      'Kozhikode',
      'Malappuram',
      'Palakkad',
      'Pathanamthitta',
      'Thiruvananthapuram',
      'Thrissur',
      'Wayanad',
    ],
    'Tamil Nadu': [
      'Chennai',
      'Coimbatore',
      'Madurai',
      'Salem',
      'Tiruchirappalli',
      'Tirunelveli',
    ],
    'Karnataka': ['Bengaluru', 'Mysuru', 'Mangaluru', 'Hubballi-Dharwad'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Nashik'],
    // Add more as needed
    'Other': ['Other'],
  };

  static List<String> get states => statesAndDistricts.keys.toList();
}
