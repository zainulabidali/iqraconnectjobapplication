import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/job_type_asset.dart';
import '../../../core/services/bannerAdWidget.dart';
import '../../../core/services/interstitial_ad_helper.dart'
    show InterstitialAdHelper;
import '../../../core/theme/app_theme.dart';
import '../../../data/models/job_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/saved_jobs_provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/auth_provider.dart';

class JobDetailScreen extends StatefulWidget {
  final JobModel job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _hasApplied = false;
  bool _checkingStatus = true;

  @override
  void initState() {
    super.initState();
    _checkApplicationStatus();
  }

  Future<void> _checkApplicationStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      final applied = await Provider.of<JobProvider>(
        context,
        listen: false,
      ).hasApplied(widget.job.id, user.uid);
      if (mounted) {
        setState(() {
          _hasApplied = applied;
          _checkingStatus = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _checkingStatus = false;
        });
      }
    }
  }

  Future<void> _applyViaWhatsApp() async {
    final String message =
        "Assalamu alaikum, I am interested in the ${widget.job.title} position at ${widget.job.company}.";
    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/${widget.job.whatsapp}?text=${Uri.encodeComponent(message)}",
    );

    try {
      final launched = await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        // ✅ SUCCESS → SAFE PLACE for interstitial
        InterstitialAdHelper.showAd();
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      if (mounted) {
        // ❌ NO ADS HERE
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open WhatsApp: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final authProvider = Provider.of<AuthProvider>(context);
    final isOwner = authProvider.user?.uid == widget.job.posterId;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Details"),
        actions: [
          Consumer<SavedJobsProvider>(
            builder: (context, savedJobsProvider, child) {
              final isSaved = savedJobsProvider.isJobSaved(widget.job.id);
              return IconButton(
                onPressed: () {
                  savedJobsProvider.toggleSaveJob(widget.job.id);
                },
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? AppTheme.softLavender : Colors.white,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.transparent,
              child: Image.asset(JobTypeAsset.getIcon(widget.job.jobType)),
            ),
            Text(
              widget.job.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.job.company,
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildCapsule(widget.job.jobType),
                _buildCapsule("₹ -${widget.job.salary}"),
                _buildCapsule("${widget.job.district}, ${widget.job.state}"),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Job Description",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.softLavender,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.job.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Posted on: ${dateFormat.format(widget.job.postedAt)}",
              style: const TextStyle(color: Colors.white30, fontSize: 13),
            ),
            const SizedBox(height: 56),

            // Action Buttons
            if (!isOwner) ...[
              if (_hasApplied)
                const SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: Center(
                    child: Text(
                      "You have applied for this job",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                )
              else if (_checkingStatus)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    /* WhatsApp Button - apply only whatsapp*/
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton.icon(
                          onPressed: () => _applyViaWhatsApp(),
                          icon: const FaIcon(
                            FontAwesomeIcons.whatsapp,
                            color: Color(0xFF25D366),
                          ),
                          label: const Text("Apply Now"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF25D366),
                            side: const BorderSide(
                              color: Color.fromARGB(137, 33, 236, 2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    /* Call Button - apply only call*/
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final Uri callUrl = Uri(
                              scheme: 'tel',
                              path: widget.job.whatsapp,
                            );
                            if (await canLaunchUrl(callUrl)) {
                              await launchUrl(callUrl);
                              // ✅ SUCCESS → SAFE PLACE for interstitial
                              InterstitialAdHelper.showAd();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Could not launch phone dialer',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.call,
                            color: Colors.lightBlueAccent,
                          ),
                          label: const Text("Call Now"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.lightBlueAccent,
                            side: const BorderSide(
                              color: Colors.lightBlueAccent,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    /* Apply In-App Button */
                  ],
                ),
            ] else
              const Center(
                child: Text(
                  "You posted this job",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BannerAdWidget(),
    );
  }

  Widget _buildCapsule(String text) {
    return Chip(
      label: Text(text),
      backgroundColor: const Color.fromARGB(255, 42, 52, 81),
      labelStyle: const TextStyle(color: Colors.white),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
