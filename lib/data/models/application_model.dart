import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus { pending, viewed, accepted, rejected }

class ApplicationModel {
  final String id;
  final String jobId;
  final String applicantId;
  final String applicantName;
  final String applicantEmail;
  final String applicantPhone;
  final String? resumeUrl;
  final String? coverLetter;
  final ApplicationStatus status;
  final DateTime appliedAt;

  ApplicationModel({
    required this.id,
    required this.jobId,
    required this.applicantId,
    required this.applicantName,
    required this.applicantEmail,
    required this.applicantPhone,
    this.resumeUrl,
    this.coverLetter,
    required this.status,
    required this.appliedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'applicantId': applicantId,
      'applicantName': applicantName,
      'applicantEmail': applicantEmail,
      'applicantPhone': applicantPhone,
      'resumeUrl': resumeUrl,
      'coverLetter': coverLetter,
      'status': status.name,
      'appliedAt': Timestamp.fromDate(appliedAt),
    };
  }

  factory ApplicationModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ApplicationModel(
      id: doc.id,
      jobId: data['jobId'] ?? '',
      applicantId: data['applicantId'] ?? '',
      applicantName: data['applicantName'] ?? '',
      applicantEmail: data['applicantEmail'] ?? '',
      applicantPhone: data['applicantPhone'] ?? '',
      resumeUrl: data['resumeUrl'],
      coverLetter: data['coverLetter'],
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => ApplicationStatus.pending,
      ),
      appliedAt: (data['appliedAt'] as Timestamp).toDate(),
    );
  }
}
