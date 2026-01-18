
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/bannerAdWidget.dart';
import '../../../core/services/interstitial_ad_helper.dart';
import '../../providers/job_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../jobs/post_job_screen.dart';
import '../jobs/job_detail_screen.dart';
import '../../widgets/job_card.dart';
import '../../widgets/app_drawer.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/filter_bottom_sheet.dart';
import '../profile/profile_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    InterstitialAdHelper.loadAd(); // ✅ Load early
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // SizedBox(height: MediaQuery.of(context).padding.top),
          // Custom Header
          _buildCustomHeader(context),
          Expanded(
            child: Consumer<JobProvider>(
              builder: (context, jobProvider, child) {
                // Initial Loading
                if (jobProvider.isLoading && jobProvider.allJobs.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final jobs = jobProvider.filteredJobs;

                if (jobs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No jobs found.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (!jobProvider.isMoreLoading &&
                        jobProvider.hasMore &&
                        scrollInfo.metrics.pixels >=
                            scrollInfo.metrics.maxScrollExtent - 200) {
                      // Load next page
                      jobProvider.loadJobs();
                    }
                    return false;
                  },
                  child: RefreshIndicator(
                    onRefresh: () => jobProvider.loadJobs(refresh: true),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 110),
                      // Add 1 to itemCount for the loading indicator at bottom
                      itemCount: jobs.length + (jobProvider.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == jobs.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final job = jobs[index];
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
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostJobScreen()),
          );
        },
        backgroundColor: Color.fromARGB(255, 217, 217, 217),

        label: const Text(
          "Post Job",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        // icon: const Icon(Icons.add, color: AppTheme.darkBackground),
      ),
      bottomNavigationBar: BannerAdWidget(),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final user = profileProvider.currentUserProfile;
    final userName = user?.name ?? "Job Seeker";

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
              const Spacer(),

              /// 🔔 Notification Icon
              IconButton(
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
              ),

              /// 👤 Profile Icon Button (UPDATED)
              IconButton(
                icon: const Icon(
                  Icons.person,
                  color: AppTheme.softLavender,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
            ],
          ),

          // const SizedBox(height: 2),

          /// Greeting Text
          Padding(
            padding: const EdgeInsets.only(left: 13),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Let's Find Job,",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          /// Search + Filter
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      Provider.of<JobProvider>(
                        context,
                        listen: false,
                      ).setSearchQuery(value);
                    },
                    decoration: InputDecoration(
                      hintText: "Search jobs...",
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(232, 255, 255, 255),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color.fromARGB(217, 255, 255, 255),
                      ),

                      /// 🔹 Border with width 4
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 255, 255, 255),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 193, 217, 251),
                          width: 1,
                        ),
                      ),

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppTheme.softLavender,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.filter_list,
                    color: AppTheme.darkBackground,
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => const FilterBottomSheet(),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
