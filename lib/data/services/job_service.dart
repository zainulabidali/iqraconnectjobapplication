import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';
import '../../core/utils/string_utils.dart';

class JobService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _jobsCollection => _db.collection('jobs');

  // Create Job
  Future<void> createJob(JobModel job) async {
    try {
      if (job.id.isEmpty) {
        await _jobsCollection.add(job.toMap());
      } else {
        await _jobsCollection.doc(job.id).set(job.toMap());
      }
    } catch (e) {
      rethrow;
    }
  }

  // Create or Update Job with normalized fields
  Future<void> createOrUpdateJob(JobModel job) async {
    try {
      final jobData = job.toMap();

      if (job.id.isEmpty) {
        // For new jobs, the toMap() method already includes the normalized field
        await _jobsCollection.add(jobData);
      } else {
        // For existing jobs, update with normalized field
        await _jobsCollection.doc(job.id).set(jobData);
      }
    } catch (e) {
      rethrow;
    }
  }

  // ✅ FIXED: Latest, non-expired jobs (Sorted by postedAt DESC)
  Stream<List<JobModel>> getJobsStream() {
    return _jobsCollection
        .orderBy('postedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((d) => JobModel.fromSnapshot(d))
              .where((job) => job.expiresAt.isAfter(DateTime.now()))
              .toList();
        });
  }

  // ✅ FIXED: Filtered jobs (Sorted by postedAt DESC)
  Stream<List<JobModel>> getFilteredJobs({
    String? state,
    String? district,
    String? jobType,
    String? role,
  }) {
    // START with base collection, NO orderBy here to avoid "Index Needed" errors
    Query query = _jobsCollection;

    // Apply exact match filters for state, district, and jobType
    if (state != null && state.isNotEmpty) {
      query = query.where('state', isEqualTo: state);
      print("JobService: Applying state filter: $state");
    }
    if (district != null && district.isNotEmpty) {
      query = query.where('district', isEqualTo: district);
      print("JobService: Applying district filter: $district");
    }
    if (jobType != null &&
        jobType.isNotEmpty &&
        jobType != 'All' &&
        jobType != 'Both') {
      // Query using the normalized jobType field in Firestore
      // For backward compatibility, we'll use the normalized field
      query = query.where('jobTypeNormalized', isEqualTo: jobType);
      print("JobService: Applying jobType filter: $jobType");
    }
    if (role != null && role.isNotEmpty) {
      query = query.where('role', isEqualTo: role);
      print("JobService: Applying role filter: $role");
    }

    // DEBUG LOGS
    print(
      "JobService: Fetching jobs with filters - State=$state, District=$district, JobType=$jobType, Role=$role",
    );

    return query.snapshots().map((snapshot) {
      print("JobService: Firestore returned ${snapshot.docs.length} docs.");
      var jobs = snapshot.docs
          .map((d) => JobModel.fromSnapshot(d))
          .where((job) => job.expiresAt.isAfter(DateTime.now()))
          .toList();

      // Client-side Sort (Safe & Easy)
      jobs.sort((a, b) => b.postedAt.compareTo(a.postedAt));
      print("JobService: After filtering expired jobs: ${jobs.length}");

      return jobs;
    });
  }

  // Get jobs by user
  Stream<List<JobModel>> getJobsByUser(String uid) {
    return _db
        .collection('jobs')
        .where('posterId', isEqualTo: uid)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => JobModel.fromSnapshot(doc))
              .toList();
        });
  }

  // Update Job
  Future<void> updateJob(JobModel job) async {
    // Use set instead of update to ensure the normalized field is included
    await _db.collection('jobs').doc(job.id).set(job.toMap());
  }

  // Delete Job
  Future<void> deleteJob(String jobId) async {
    await _db.collection('jobs').doc(jobId).delete();
  }
}
