import 'package:cloud_firestore/cloud_firestore.dart';
import 'string_utils.dart';

class MigrationUtils {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Migrates existing jobs to include normalized jobType field
  static Future<void> migrateJobTypes() async {
    print("Starting job type migration...");

    final snapshot = await _firestore.collection('jobs').get();
    int migratedCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final jobType = data['jobType'] ?? '';
      final currentNormalized = data['jobTypeNormalized'];
      final expectedNormalized = StringUtils.normalizeAndFix(jobType);

      // Update if the normalized field doesn't exist or if it's incorrect (e.g. has old typo)
      if (currentNormalized != expectedNormalized) {
        try {
          await _firestore.collection('jobs').doc(doc.id).update({
            'jobTypeNormalized': expectedNormalized,
          });

          print(
            "Migrated job ${doc.id}: $jobType -> $expectedNormalized (was: $currentNormalized)",
          );
          migratedCount++;
        } catch (e) {
          print("Failed to migrate job ${doc.id}: $e");
        }
      }
    }

    print("Migration completed. Migrated $migratedCount jobs.");
  }

  /// Updates a single job document with normalized fields
  static Future<void> updateJobWithNormalizedFields(
    String jobId,
    String jobType,
  ) async {
    final normalizedJobType = StringUtils.normalizeAndFix(jobType);

    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'jobTypeNormalized': normalizedJobType,
      });
      print("Updated job $jobId with normalized jobType: $normalizedJobType");
    } catch (e) {
      print("Failed to update job $jobId: $e");
    }
  }
}
