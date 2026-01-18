import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/locations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../providers/profile_provider.dart';
import '../splash_screen.dart';

class ProfileCreationScreen extends StatefulWidget {
  final UserModel? user;

  const ProfileCreationScreen({super.key, this.user});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _studiedPlaceController = TextEditingController();
  final TextEditingController _sanadController = TextEditingController();
  final TextEditingController _qualificationController =
      TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  String? _selectedState;
  String? _selectedDistrict;

  @override
  void initState() {
    super.initState();

    if (widget.user != null) {
      final user = widget.user!;
      _nameController.text = user.name;

      if (user.phone.startsWith('+91 ')) {
        _phoneController.text = user.phone.substring(4);
      } else if (user.phone.startsWith('+91')) {
        _phoneController.text = user.phone.substring(3);
      } else {
        _phoneController.text = user.phone;
      }

      _selectedState = user.state;
      _selectedDistrict = user.district;
      _studiedPlaceController.text = user.studiedPlace ?? '';
      _sanadController.text = user.sanad ?? '';
      _qualificationController.text = user.qualification ?? '';
      _experienceController.text = user.experience ?? '';
    } else {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser?.displayName != null) {
        _nameController.text = firebaseUser!.displayName!;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _studiedPlaceController.dispose();
    _sanadController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    String? helper,
    String? prefix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helper,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
      helperStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      prefixText: prefix,
      prefixStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: AppTheme.cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppTheme.primaryColor.withOpacity(0.9),
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.8)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.9)),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  void _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedState == null || _selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select State and District')),
      );
      return;
    }

    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) return;

    final userModel = UserModel(
      uid: firebaseUser.uid,
      name: _nameController.text.trim(),
      phone: "+91 ${_phoneController.text.trim()}",
      state: _selectedState!,
      district: _selectedDistrict!,
      studiedPlace: _studiedPlaceController.text.trim(),
      sanad: _sanadController.text.trim(),
      qualification: _qualificationController.text.trim(),
      experience: _experienceController.text.trim(),
      subjects: null,
      profileCompleted: true, // Mark as completed
    );

    try {
      await profileProvider.saveUserProfile(userModel);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile saved successfully")),
        );
        // Navigate back to splash to let it handle the flow
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SplashScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(title: const Text("Create Profile"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Complete your profile to continue",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),

              _section("Basic Information", [
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(label: "Full Name *"),
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: _inputDecoration(
                    label: "WhatsApp Number *",
                    hint: "9876543210",
                    prefix: "+91 ",
                    helper: "Job contacts will come via WhatsApp",
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Required";
                    if (v.length != 10) return "Must be 10 digits";
                    if (!RegExp(r'^[0-9]+$').hasMatch(v)) {
                      return "Numbers only";
                    }
                    return null;
                  },
                ),
              ]),

              _section("Location", [
                DropdownButtonFormField<String>(
                  value: _selectedState,
                  decoration: _inputDecoration(label: "State *"),
                  items: LocationConstants.states
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedState = v;
                      _selectedDistrict = null;
                    });
                  },
                  validator: (v) => v == null ? "Required" : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  decoration: _inputDecoration(label: "District *"),
                  items: _selectedState == null
                      ? []
                      : LocationConstants.statesAndDistricts[_selectedState]!
                            .map(
                              (d) => DropdownMenuItem(value: d, child: Text(d)),
                            )
                            .toList(),
                  onChanged: (v) => setState(() => _selectedDistrict = v),
                  validator: (v) => v == null ? "Required" : null,
                ),
              ]),

              _section("Additional Details (Optional)", [
                TextFormField(
                  controller: _studiedPlaceController,
                  decoration: _inputDecoration(label: "Studied Place"),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sanadController,
                  decoration: _inputDecoration(label: "Sanad"),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _qualificationController,
                  decoration: _inputDecoration(label: "Qualification"),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _experienceController,
                  decoration: _inputDecoration(label: "Experience"),
                ),
              ]),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.softLavender,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _submitProfile,
                  child: const Text(
                    "Save & Continue",
                    style: TextStyle(
                      color: AppTheme.darkBackground,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
