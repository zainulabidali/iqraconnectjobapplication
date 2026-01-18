import 'package:iqra_connect/core/constants/job_type_asset.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/job_model.dart';

class JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;
  final VoidCallback? onSaveTap;
  final bool isSaved;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.onSaveTap,
    this.isSaved = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(90, 90, 110, 180),
                Color.fromARGB(60, 60, 80, 160),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TOP ROW – ICON + TITLE
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: AssetImage(
                            JobTypeAsset.getIcon(job.jobType),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        job.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// COMPANY
                Text(
                  job.company,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),

                Row(
                  children: [
                    _JobTypeChip(job.jobType),
                    const SizedBox(width: 6),

                    /// SALARY (SAFE PILL STYLE)
                    if (job.salary.trim().isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: AppTheme.softLavender.withOpacity(0.15),
                          border: Border.all(
                            color: AppTheme.softLavender.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          "₹ ${job.salary}",
                          style: const TextStyle(
                            color: AppTheme.softLavender,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                  ],
                ),

                /// LOCATION + SAVE + DATE (SAME STRUCTURE)
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.white54,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "${job.district}, ${job.state}",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        IconButton(
                          onPressed: onSaveTap,
                          splashRadius: 22,
                          icon: Icon(
                            isSaved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_outline_rounded,
                            color: isSaved
                                ? AppTheme.softLavender
                                : Colors.white70,
                          ),
                        ),
                        Text(
                          dateFormat.format(job.postedAt),
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// JOB TYPE CHIP – SAME MODEL BUT ICON + TEXT
class _JobTypeChip extends StatelessWidget {
  final String text;

  const _JobTypeChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: AppTheme.softLavender.withOpacity(0.15),
        border: Border.all(
          color: AppTheme.softLavender.withOpacity(0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
