import 'package:iqra_connect/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../screens/info/about_app_screen.dart';
import '../screens/info/contact_us_screen.dart';
import '../screens/info/feedback_screen.dart';
import '../screens/info/privacy_policy_screen.dart';
import '../screens/jobs/my_posted_jobs_screen.dart';
import '../screens/jobs/post_job_screen.dart';
import '../screens/jobs/saved_jobs_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Drawer(
      backgroundColor: AppTheme.darkBackground,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryColor),
            accountName: InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: Text(
                user?.displayName ?? "User",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            accountEmail: Text(user?.email ?? ""),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppTheme.softLavender,
              child: Text(
                user?.displayName?.substring(0, 1).toUpperCase() ?? "U",
                style: const TextStyle(
                  fontSize: 40.0,
                  color: AppTheme.darkBackground,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white70),
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context); // Close drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle, color: Colors.white70),
            title: const Text(
              'Post a Job',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PostJobScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark, color: Colors.white70),
            title: const Text(
              'Saved Jobs',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedJobsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt, color: Colors.white70),
            title: const Text(
              'My Posted Jobs',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyPostedJobsScreen()),
              );
            },
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.white70),
            title: const Text(
              'About App',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutAppScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.white70),
            title: const Text(
              'Privacy Policy',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              );
            },
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.feedback, color: Colors.white70),
            title: const Text(
              'Feedback',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeedbackScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail, color: Colors.white70),
            title: const Text(
              'Contact Us',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactUsScreen()),
              );
            },
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(
                context,
                listen: false,
              ).signOut(context);
            },
          ),
        ],
      ),
    );
  }
}
