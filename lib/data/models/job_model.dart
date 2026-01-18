import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/string_utils.dart';

class JobModel {
  final String id; // Firestore Doc ID
  final String posterId;
  final String title;
  final String company; // Institution Name
  final String state;
  final String district;
  final String description;
  final String jobType; // Full Time, Part Time
  final String salary;
  final String whatsapp;
  final DateTime postedAt;
  final DateTime expiresAt;
  final bool isFlagged;
  final String role;

  final DocumentSnapshot? snapshot;

  JobModel({
    required this.id,
    required this.posterId,
    required this.title,
    required this.company,
    required this.state,
    required this.district,
    required this.description,
    required this.jobType,
    required this.salary,
    required this.whatsapp,
    required this.postedAt,
    required this.expiresAt,
    this.isFlagged = false,
    this.role = '',
    this.snapshot,
  });

  Map<String, dynamic> toMap() {
    // Ensure the jobType is normalized when saving to prevent typos from persisting
    String normalizedJobType = StringUtils.normalizeAndFix(jobType);

    return {
      'posterId': posterId,
      'title': title,
      'company': company,
      'state': state,
      'district': district,
      'description': description,
      'jobType': jobType, // Keep original for display purposes
      'jobTypeNormalized': normalizedJobType, // Store normalized for querying
      'salary': salary,
      'whatsapp': whatsapp,
      'postedAt': Timestamp.fromDate(postedAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'isFlagged': isFlagged,
      'role': role,
    };
  }

  factory JobModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobModel(
      id: doc.id,
      posterId: data['posterId'] ?? '',
      title: data['title'] ?? '',
      company: data['company'] ?? '',
      state: data['state'] ?? '',
      district: data['district'] ?? '',
      description: data['description'] ?? '',
      jobType: data['jobType'] ?? 'Full Time',
      salary: data['salary'] ?? '',
      whatsapp: data['whatsapp'] ?? '',
      postedAt: (data['postedAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      isFlagged: data['isFlagged'] ?? false,
      role: data['role'] ?? '',
      snapshot: doc,
    );
  }
}
