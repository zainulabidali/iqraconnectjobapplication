import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/job_provider.dart';
import '../../providers/saved_jobs_provider.dart';
import '../jobs/job_detail_screen.dart';
import '../../widgets/job_card.dart';

class SavedJobsScreen extends StatelessWidget {
  const SavedJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        title: const Text('Saved Jobs', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer2<SavedJobsProvider, JobProvider>(
        builder: (context, savedJobsProvider, jobProvider, child) {
          final savedIds = savedJobsProvider.savedJobIds;

          if (savedIds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 80, color: Colors.white24),
                  const SizedBox(height: 16),
                  const Text(
                    'No saved jobs yet',
                    style: TextStyle(color: Colors.white54, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          // Filter jobs from JobProvider that are in savedIds
          final savedJobs = jobProvider.allJobs
              .where((job) => savedIds.contains(job.id))
              .toList();

          if (savedJobs.isEmpty) {
            // This can happen if saved IDs exist but the jobs aren't loaded in JobProvider yet
            // or the job was deleted from Firestore but ID remains in local storage.
            // We might want to attempt to fetch specific jobs here or just show empty for now logic.
            // For now, assuming JobProvider has the cache of jobs.
            // If JobProvider only has a subset, this might be partial.
            // Ideally we should fetch these jobs if missing, but keeping it simple as per request.
            return const Center(
              child: Text(
                'No saved jobs found in current listing',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return ListView.builder(
            itemCount: savedJobs.length,
            itemBuilder: (context, index) {
              final job = savedJobs[index];
              return JobCard(
                job: job,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobDetailScreen(job: job),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
