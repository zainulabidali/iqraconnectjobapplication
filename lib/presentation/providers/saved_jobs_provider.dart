import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SavedJobsProvider extends ChangeNotifier {
  Box<dynamic>? _savedJobsBox;
  List<String> _savedJobIds = [];

  List<String> get savedJobIds => _savedJobIds;

  SavedJobsProvider() {
    _init();
  }

  Future<void> _init() async {
    _savedJobsBox = await Hive.openBox('saved_jobs');
    _loadSavedJobs();
  }

  void _loadSavedJobs() {
    if (_savedJobsBox != null) {
      _savedJobIds = _savedJobsBox!.values.cast<String>().toList();
      notifyListeners();
    }
  }

  bool isJobSaved(String jobId) {
    return _savedJobIds.contains(jobId);
  }

  Future<void> toggleSaveJob(String jobId) async {
    if (_savedJobsBox == null) return;

    if (_savedJobIds.contains(jobId)) {
      // Unsave
      _savedJobIds.remove(jobId);
      // Find key for value to delete from Hive
      final keyToDelete = _savedJobsBox!.keys.firstWhere(
        (k) => _savedJobsBox!.get(k) == jobId,
        orElse: () => null,
      );
      if (keyToDelete != null) {
        await _savedJobsBox!.delete(keyToDelete);
      }
    } else {
      // Save
      _savedJobIds.add(jobId);
      await _savedJobsBox!.add(jobId);
    }
    notifyListeners();
  }

  void clearData() {
    _savedJobIds = [];
    notifyListeners();
  }
}
