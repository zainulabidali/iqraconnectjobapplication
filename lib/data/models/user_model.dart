class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String state;
  final String district;
  final String? studiedPlace;
  final String? sanad;
  final String? qualification;
  final String? experience;
  final String? subjects; // "Subjects / responsibility"
  final String? fcmToken;
  final bool profileCompleted;

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.state,
    required this.district,
    this.studiedPlace,
    this.sanad,
    this.qualification,
    this.experience,
    this.subjects,
    this.fcmToken,
    this.profileCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'state': state,
      'district': district,
      'studiedPlace': studiedPlace,
      'sanad': sanad,
      'qualification': qualification,
      'experience': experience,
      'subjects': subjects,
      'fcmToken': fcmToken,
      'profileCompleted': profileCompleted,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      state: map['state'] ?? '',
      district: map['district'] ?? '',
      studiedPlace: map['studiedPlace'],
      sanad: map['sanad'],
      qualification: map['qualification'],
      experience: map['experience'],
      subjects: map['subjects'],
      fcmToken: map['fcmToken'],
      profileCompleted: map['profileCompleted'] ?? false,
    );
  }
}
