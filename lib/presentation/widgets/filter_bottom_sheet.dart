import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/string_utils.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet>
    with SingleTickerProviderStateMixin {
  String? _selectedState;
  String? _selectedDistrict;
  String _selectedJobType = "Both";
  String? _selectedRole;

  late AnimationController _controller;

  // Hardcoded lists (can be replaced with Firebase later)
  final List<String> _states = [
    "Kerala",
    "Tamil Nadu",
    "Karnataka",
    "Maharashtra",
  ];

  final Map<String, List<String>> _districts = {
    "Kerala": [
      "Thiruvananthapuram",
      "Kollam",
      "Pathanamthitta",
      "Alappuzha",
      "Kottayam",
      "Idukki",
      "Ernakulam",
      "Thrissur",
      "Palakkad",
      "Malappuram",
      "Kozhikode",
      "Wayanad",
      "Kannur",
      "Kasaragod",
    ],
    "Tamil Nadu": ["Chennai", "Coimbatore", "Madurai"],
    "Karnataka": ["Bangalore", "Mysore", "Mangalore"],
    "Maharashtra": ["Mumbai", "Pune", "Nagpur"],
  };

  final List<String> _jobTypes = [
    "Both",
    'Masjid & Madrasa',
    'Educational Institute',
    'Community & Welfare', // Fixed typo from 'Walfare'
    'Shops & Business',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..forward();

    final provider = Provider.of<JobProvider>(context, listen: false);

    _selectedState = provider.selectedState;
    _selectedDistrict = provider.selectedDistrict;
    _selectedJobType = provider.selectedJobType.isNotEmpty
        ? provider.selectedJobType
        : "Both";
    _selectedRole = provider.selectedRole;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.darkBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),

                _buildDropdown("State", _selectedState, _states, (val) {
                  setState(() {
                    _selectedState = val;
                    _selectedDistrict = null;
                  });
                }),

                const SizedBox(height: 16),

                _buildDropdown(
                  "District",
                  _selectedDistrict,
                  _selectedState != null
                      ? (_districts[_selectedState] ?? [])
                      : [],
                  (val) => setState(() => _selectedDistrict = val),
                  enabled:
                      _selectedState != null &&
                      (_districts[_selectedState]?.isNotEmpty ?? false),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Job Type",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
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
                        selectedColor: AppTheme.softLavender,
                        backgroundColor: Colors.white.withOpacity(0.08),
                        elevation: isSelected ? 4 : 0,
                        pressElevation: 6,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.darkBackground
                              : Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.softLavender,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: _applyFilters,
                    child: const Text(
                      "Apply Filters",
                      style: TextStyle(
                        color: AppTheme.darkBackground,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  // SizedBox(height: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Filter Jobs",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: _resetFilters,
          child: const Text(
            "Reset",
            style: TextStyle(color: AppTheme.softLavender),
          ),
        ),
      ],
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedState = null;
      _selectedDistrict = null;
      _selectedJobType = "Both";
      _selectedRole = null;
    });

    Provider.of<JobProvider>(context, listen: false).clearFilters();

    Navigator.pop(context);
  }

  void _applyFilters() {
    // Normalize the job type before sending to provider
    String? jobTypeToSend;
    if (_selectedJobType != "Both") {
      jobTypeToSend = _selectedJobType;
    }

    print(
      "FilterBottomSheet: Applying filters -> State=$_selectedState, District=$_selectedDistrict, JobType=$jobTypeToSend",
    );

    Provider.of<JobProvider>(context, listen: false).setFilter(
      state: _selectedState,
      district: _selectedDistrict,
      jobType: jobTypeToSend,
      role: _selectedRole,
    );

    Navigator.pop(context);
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged, {
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: enabled ? 1 : 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: enabled
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: Text(
                  "Select $label",
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                dropdownColor: AppTheme.darkBackground,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                style: const TextStyle(color: Colors.white),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
