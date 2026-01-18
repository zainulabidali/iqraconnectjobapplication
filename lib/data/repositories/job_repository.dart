import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';
import '../models/application_model.dart';
import '../../core/utils/string_utils.dart';

abstract class JobRepository {
  Future<List<JobModel>> getJobs({
    int limit = 10,
    DocumentSnapshot? startAfter,
    String? typeFilter,
    String? districtFilter,
  });

  Future<void> createJob(JobModel job);
  Future<void> deleteJob(String jobId);
  Future<void> applyForJob(String jobId, ApplicationModel application);
  Future<bool> hasApplied(String jobId, String userId);
  Future<List<ApplicationModel>> getJobApplications(String jobId);
}

class JobRepositoryImpl implements JobRepository {
  final FirebaseFirestore _firestore;

  JobRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<JobModel>> getJobs({
    int limit = 10,
    DocumentSnapshot? startAfter,
    String? typeFilter,
    String? districtFilter,
  }) async {
    Query query = _firestore
        .collection('jobs')
        .orderBy(
          'expiresAt',
          descending: false,
        ) // Show soon-to-expire or just verify active.
        // Logic: We want to show available jobs. Most querying scenarios might want newest first.
        // But the index requirements said: composite with expiresAt.
        // Let's stick to standard "Newest First" (postedAt desc) AND filter where expiresAt > now.
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('postedAt', descending: true);

    // Apply composite filters if they exist
    if (typeFilter != null &&
        typeFilter.isNotEmpty &&
        typeFilter.toLowerCase() != 'all' &&
        typeFilter.toLowerCase() != 'both') {
      // In the provider, we already normalize if needed, but here we should be safe.
      // However, we need import to use StringUtils if we want to normalize here too.
      // Let's check imports in job_repository.dart.
      query = query.where('jobTypeNormalized',
          isEqualTo: StringUtils.normalizeAndFix(typeFilter));
    }

    if (districtFilter != null &&
        districtFilter.isNotEmpty &&
        districtFilter != 'All Kerala') {
      query = query.where('district', isEqualTo: districtFilter);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.limit(limit).get();
    return snapshot.docs.map((doc) => JobModel.fromSnapshot(doc)).toList();
  }

  @override
  Future<void> createJob(JobModel job) async {
    await _firestore.collection('jobs').add(job.toMap());
  }

  @override
  Future<void> deleteJob(String jobId) async {
    await _firestore.collection('jobs').doc(jobId).delete();
  }

  @override
  Future<void> applyForJob(String jobId, ApplicationModel application) async {
    final jobRef = _firestore.collection('jobs').doc(jobId);
    final appRef =
        jobRef.collection('applications').doc(application.applicantId);

    // Use transaction to ensure consistency (check if already applied)
    await _firestore.runTransaction((transaction) async {
      final appDoc = await transaction.get(appRef);
      if (appDoc.exists) {
        throw Exception("You have already applied for this job.");
      }
      transaction.set(appRef, application.toMap());
    });
  }

  @override
  Future<bool> hasApplied(String jobId, String userId) async {
    final doc = await _firestore
        .collection('jobs')
        .doc(jobId)
        .collection('applications')
        .doc(userId)
        .get();
    return doc.exists;
  }

  @override
  Future<List<ApplicationModel>> getJobApplications(String jobId) async {
    final snapshot = await _firestore
        .collection('jobs')
        .doc(jobId)
        .collection('applications')
        .orderBy('appliedAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => ApplicationModel.fromSnapshot(doc))
        .toList();
  }
}
