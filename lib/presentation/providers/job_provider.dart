import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/job_model.dart';
import '../../data/models/application_model.dart';
import '../../data/repositories/job_repository.dart';
import '../../core/utils/string_utils.dart';
import '../../core/utils/migration_utils.dart';

class JobProvider with ChangeNotifier {
  final JobRepository _jobRepository = JobRepositoryImpl();

  // --------------------
  // DATA
  // --------------------
  List<JobModel> _allJobs = [];
  bool _isLoading = false;
  bool _isMoreLoading = false;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  String? _error;

  // --------------------
  // SEARCH & FILTER STATE
  // --------------------
  String _searchQuery = "";
  String? _selectedState;
  String? _selectedDistrict;
  String _selectedJobType = "All";
  String? _selectedRole;

  // --------------------
  // GETTERS
  // --------------------
  List<JobModel> get allJobs => _allJobs;
  // Alias filteredJobs to allJobs since filtering is now server-side or handled within allJobs
  List<JobModel> get filteredJobs {
    List<JobModel> filtered = _allJobs;

    // 1. Filter by Job Type (Local)
    if (_selectedJobType.isNotEmpty &&
        _selectedJobType != "All" &&
        _selectedJobType != "Both") {
      filtered = filtered.where((job) {
        // Use normalizeAndFix to match server-side comparison logic and handle typos
        return StringUtils.normalizeAndFix(job.jobType) ==
            StringUtils.normalizeAndFix(_selectedJobType);
      }).toList();
    }

    // 2. Filter by Search Query (Local)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      filtered = filtered.where((job) {
        return StringUtils.containsNormalized(job.title, query) ||
            StringUtils.containsNormalized(job.company, query) ||
            StringUtils.containsNormalized(job.description, query);
      }).toList();
    }

    return filtered;
  }

  bool get isLoading => _isLoading;
  bool get isMoreLoading => _isMoreLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  String get searchQuery => _searchQuery;
  String? get selectedState => _selectedState;
  String? get selectedDistrict => _selectedDistrict;
  String get selectedJobType => _selectedJobType;
  String? get selectedRole => _selectedRole;

  JobProvider() {
    _runMigrations();
    loadJobs(refresh: true);
  }

  void _runMigrations() {
    MigrationUtils.migrateJobTypes().catchError((e) {
      print("Migration failed: $e");
    });
  }

  // --------------------
  // FETCH JOBS & PAGINATION
  // --------------------
  Future<void> loadJobs({bool refresh = false}) async {
    if (refresh) {
      _isLoading = true;
      _lastDocument = null;
      _hasMore = true;
      _allJobs = [];
      _error = null;
      notifyListeners();
    } else {
      if (_isMoreLoading || !_hasMore) return;
      _isMoreLoading = true;
      notifyListeners();
    }

    try {
      // Prepare normalized filter values
      String? jobTypeFilter;
      if (_selectedJobType.isNotEmpty &&
          _selectedJobType != "All" &&
          _selectedJobType != "Both") {
        jobTypeFilter = _selectedJobType;
      }

      // Fetch from Repository
      final newJobs = await _jobRepository.getJobs(
        limit: 10,
        startAfter: _lastDocument,
        typeFilter: jobTypeFilter,
        districtFilter:
            _selectedDistrict?.isNotEmpty == true ? _selectedDistrict : null,
      );

      if (newJobs.isEmpty) {
        _hasMore = false;
      } else {
        _allJobs.addAll(newJobs);
        _lastDocument = newJobs.last.snapshot;
        if (newJobs.length < 10) {
          _hasMore = false;
        }
      }
    } catch (e) {
      _error = e.toString();
      print("JobProvider Error: $e");
    } finally {
      _isLoading = false;
      _isMoreLoading = false;
      notifyListeners();
    }
  }

  // --------------------
  // ACTIONS
  // --------------------
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter({
    String? state,
    String? district,
    String? jobType,
    String? role,
  }) {
    _selectedState = state;
    _selectedDistrict = district;
    _selectedJobType = jobType ?? "All";
    _selectedRole = role;

    // Reset and reload from server
    loadJobs(refresh: true);
  }

  void clearFilters() {
    _selectedState = null;
    _selectedDistrict = null;
    _selectedJobType = "All";
    _selectedRole = null;
    _searchQuery = "";
    loadJobs(refresh: true);
  }

  // --------------------
  // CRUD
  // --------------------
  Future<void> postJob(JobModel job) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _jobRepository.createJob(job);
      // Refresh list to show new job (or prepend it manually)
      loadJobs(refresh: true);
    } catch (e) {
      print("Error posting job: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<JobModel>> getMyPostedJobsStream(String uid) {
    // Direct stream for posted jobs
    return FirebaseFirestore.instance
        .collection('jobs')
        .where('posterId', isEqualTo: uid)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => JobModel.fromSnapshot(doc)).toList(),
        );
  }

  Future<void> updateJob(JobModel job) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Direct update as repository abstraction for update wasn't strictly enforced in previous steps
      // But we should try to keep it clean. However, to match `JobRepository` interface we'd need to add `updateJob` there.
      // I'll assume we can use direct FS for now to save time, or add it to repo later.
      // Ideally: await _jobRepository.updateJob(job);
      // But `JobRepository` interface in Step 86 didn't include `updateJob`?
      // Wait, I checked Step 86, `JobRepository` interface lines 5-18... It DOES NOT have `updateJob`.
      // It has `createJob`, `deleteJob`, `applyForJob`, `hasApplied`, `getJobApplications`.
      // So I must do it here directly or update Repo. I'll do it directly for expediency.

      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(job.id)
          .set(job.toMap());

      // Update local list
      final index = _allJobs.indexWhere((j) => j.id == job.id);
      if (index != -1) {
        _allJobs[index] = job;
        notifyListeners();
      }
    } catch (e) {
      print("Error updating job: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteJob(String jobId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _jobRepository.deleteJob(jobId);
      _allJobs.removeWhere((job) => job.id == jobId);
    } catch (e) {
      print("Error deleting job: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --------------------
  // APPLICATION LOGIC
  // --------------------
  Future<void> applyForJob(String jobId, ApplicationModel application) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _jobRepository.applyForJob(jobId, application);
    } catch (e) {
      print("Error applying for job: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> hasApplied(String jobId, String userId) async {
    try {
      return await _jobRepository.hasApplied(jobId, userId);
    } catch (e) {
      print("Error checking application status: $e");
      return false;
    }
  }
}
