import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppTheme.darkBackground,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your privacy is important to us. This policy explains how we handle your data.',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Data Collection',
              content:
                  'We collect basic information such as your name, phone number, and location when you create a profile or post a job. This is necessary to facilitate the connection between job seekers and employers.',
            ),
            _buildSection(
              title: 'Data Usage',
              content:
                  'Your data is used to display job listings and enable direct communication via WhatsApp. We do not sell your personal data to third parties.',
            ),
            _buildSection(
              title: 'Data Storage',
              content:
                  'We use Firebase for secure cloud storage of user profiles and job listings. Saved jobs are stored locally on your device.',
            ),
            _buildSection(
              title: 'User Responsibility',
              content:
                  'Users are responsible for the information they share. Please do not share sensitive personal information in public job descriptions.',
            ),
            _buildSection(
              title: 'Contact Us',
              content:
                  'If you have any questions about this policy, please contact support.',
            ),
            const SizedBox(height: 32),
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
