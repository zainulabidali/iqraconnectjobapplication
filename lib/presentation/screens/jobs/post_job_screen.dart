import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/locations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/job_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/profile_provider.dart';
import '../../../core/services/interstitial_ad_helper.dart';


class PostJobScreen extends StatefulWidget {
  final JobModel? job;

  const PostJobScreen({super.key, this.job});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();

  String? _selectedState;
  String? _selectedDistrict;
  String _selectedJobType = 'Masjid & Madrasa';

  final List<String> _jobTypes = [
    'Masjid & Madrasa',  
    'Educational institute',
    'community & Walfare', 
    'Shops & Business',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.job != null) {
      // Edit Mode
      final job = widget.job!;
      _titleController.text = job.title;
      _companyController.text = job.company;
      _salaryController.text = job.salary;
      _descriptionController.text = job.description;

      if (job.whatsapp.startsWith('+91 ')) {
        _whatsappController.text = job.whatsapp.substring(4);
      } else if (job.whatsapp.startsWith('+91')) {
        _whatsappController.text = job.whatsapp.substring(3);
      } else {
        _whatsappController.text = job.whatsapp;
      }

      _selectedState = job.state;
      _selectedDistrict = job.district;
      _selectedJobType = job.jobType;
    } else {
      // Create Mode
      final profile = Provider.of<ProfileProvider>(
        context,
        listen: false,
      ).currentUserProfile;
      if (profile != null) {
        // Auto-fill from profile if matches pattern
        if (profile.phone.startsWith('+91 ')) {
          _whatsappController.text = profile.phone.substring(4);
        } else if (profile.phone.startsWith('+91')) {
          _whatsappController.text = profile.phone.substring(3);
        } else {
          _whatsappController.text = profile.phone;
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _salaryController.dispose();
    _descriptionController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  void _postJob() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedState == null || _selectedDistrict == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select State and District')),
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final jobProvider = Provider.of<JobProvider>(context, listen: false);

      if (authProvider.user == null) return;

      final isEditing = widget.job != null;
      final jobId = isEditing ? widget.job!.id : const Uuid().v4();
      final postedAt = isEditing ? widget.job!.postedAt : DateTime.now();
      final expiresAt = isEditing
          ? widget.job!.expiresAt
          : DateTime.now().add(const Duration(days: 14));

      final newJob = JobModel(
        id: jobId,
        posterId: authProvider.user!.uid,
        title: _titleController.text,
        company: _companyController.text,
        state: _selectedState!,
        district: _selectedDistrict!,
        description: _descriptionController.text,
        jobType: _selectedJobType,
        salary: _salaryController.text,
        whatsapp: "+91 ${_whatsappController.text}",
        postedAt: postedAt,
        expiresAt: expiresAt,
      );

      try {
        if (isEditing) {
          await jobProvider.updateJob(newJob);
          if (mounted) {
            InterstitialAdHelper.showAd(); // ✅ Show interstitial ad on update
            await Future.delayed(const Duration(seconds: 2));

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Job Updated Successfully!")),
            );
            Navigator.pop(context);
          }
        } else {
          await jobProvider.postJob(newJob);
          if (mounted) {
            InterstitialAdHelper.showAd();
            await Future.delayed(const Duration(seconds: 2));
            


            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Job Posted Successfully!")),
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text(widget.job != null ? "Update Job" : "Post a Job"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Job Basics"),
              _buildTextField(
                controller: _titleController,
                label: "Job Title",
                hint: "Ex: Muallim vacancy available",
                isRequired: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _companyController,
                label: "Institution Name / SubTitle",
                hint: "Ex: Al-Huda Madrasa",
                isRequired: true,
              ),

              const SizedBox(height: 32),
              _buildSectionTitle("Location"),
              _buildDropdown(
                label: "State",
                value: _selectedState,
                items: LocationConstants.states,
                onChanged: (value) {
                  setState(() {
                    _selectedState = value;
                    _selectedDistrict = null;
                  });
                },
                isRequired: true,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: "District",
                value: _selectedDistrict,
                items: _selectedState == null
                    ? []
                    : LocationConstants.statesAndDistricts[_selectedState] ??
                          [],
                onChanged: (value) => setState(() => _selectedDistrict = value),
                isRequired: true,
                hint: _selectedState == null
                    ? "Select State first"
                    : "Select District",
                enabled: _selectedState != null,
              ),

              const SizedBox(height: 22),
              _buildSectionTitle("Job Details & Description"),
              _buildLabel("Job Type"),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _jobTypes.map((type) {
                  final isSelected = _selectedJobType == type;

                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedJobType = type);
                      }
                    },

                    // 🔹 COLORS
                    selectedColor: const Color.fromARGB(
                      255,
                      154,
                      185,
                      223,
                    ).withOpacity(0.9),
                    backgroundColor: AppTheme.cardColor,

                    // 🔹 TEXT STYLE
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppTheme.darkBackground
                          : Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),

                    // 🔹 BORDER SHAPE
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.white.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              _buildTextField(
                controller: _salaryController,
                label: "Salary (Optional)",
                hint: "Ex: 15,000 - 20,000",
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: "Job Description (Optional)",
                hint: "Describe requirements, timings, etc.",
                maxLines: 4,
              ),

              const SizedBox(height: 32),
              _buildSectionTitle("Contact Details"),
              _buildTextField(
                controller: _whatsappController,
                label: "WhatsApp Number",
                hint: "9876543210",
                helperText: "Job applications will come via WhatsApp",
                isRequired: true,
                prefixText: "+91 ",
                keyboardType: TextInputType.number,
                maxLength: 10,
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return "WhatsApp number is required";
                  if (v.length != 10) return "Must be exactly 10 digits";
                  if (!RegExp(r'^[0-9]+$').hasMatch(v)) return "Numbers only";
                  return null;
                },
              ),

              const SizedBox(height: 48),
              Consumer<JobProvider>(
                builder: (context, provider, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _postJob,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.softLavender,
                        disabledBackgroundColor: Colors.white12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: AppTheme.softLavender.withOpacity(0.4),
                      ),
                      child: provider.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.darkBackground,
                              ),
                            )
                          : Text(
                              widget.job != null ? "Update Job" : "Post Job",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkBackground,
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.softLavender,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: " *",
              style: TextStyle(color: AppTheme.softLavender),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool isRequired = false,
    int maxLines = 1,
    String? helperText,
    String? prefixText,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired: isRequired),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          validator:
              validator ??
              (v) {
                if (isRequired && (v == null || v.isEmpty)) {
                  return "$label is required";
                }
                return null;
              },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
            helperText: helperText,
            helperStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            prefixText: prefixText,
            prefixStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: AppTheme.cardColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),

            // 🔹 DEFAULT / ENABLED BORDER
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.12),
                width: 1,
              ),
            ),

            // 🔹 FOCUSED BORDER
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.8),
                width: 1.4,
              ),
            ),

            // 🔹 ERROR BORDER
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.redAccent.withOpacity(0.8),
                width: 1,
              ),
            ),

            // 🔹 FOCUSED ERROR BORDER
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.redAccent.withOpacity(0.9),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isRequired = false,
    String? hint,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired: isRequired),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: enabled
                ? AppTheme.cardColor
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled
                  ? Colors.white.withOpacity(0.15) // normal border
                  : Colors.white.withOpacity(0.05), // disabled border
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                hint ?? "Select $label",
                style: TextStyle(color: Colors.white.withOpacity(0.3)),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              dropdownColor: AppTheme.cardColor,
              items: items.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: enabled ? onChanged : null,
              validator: (v) {
                if (isRequired && v == null) return "$label is required";
                return null;
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: enabled ? Colors.white70 : Colors.white30,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
