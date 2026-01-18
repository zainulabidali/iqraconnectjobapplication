import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('About App'),
        backgroundColor: AppTheme.darkBackground,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.work_outline,
                      size: 50,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Job Finder App',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'For Ustads & Islamic Institutions',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(
              title: 'Purpose',
              content:
                  'This app connects Ustads seeking employment with Masjids and Islamic institutions looking for qualified individuals. It simplifies the process of finding and posting religious job opportunities.',
            ),
            _buildSection(
              title: 'How It Works',
              content:
                  'Institutions can post job openings with details. Job seekers can browse these listings and apply directly via WhatsApp. Users can also save jobs for later viewing.',
            ),
            _buildSection(
              title: 'Disclaimer',
              content:
                  'Please note that this app does not verify every job posting. We encourage all users to verify details personally before making any commitments or payments. Exercise caution and due diligence.',
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: Colors.white30, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.softLavender,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
