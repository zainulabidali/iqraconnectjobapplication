import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Firestore Write Logic
  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Prepare Data
      final Map<String, dynamic> feedbackData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'message': _messageController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      // 2. Write to Firestore 'feedback' collection
      await FirebaseFirestore.instance.collection('feedback').add(feedbackData);

      // 3. Success Feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Clear form
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
        FocusScope.of(context).unfocus(); // Close keyboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting feedback: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Initial Validator Logic
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    // Simple Regex for Email
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your feedback';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text("Feedback"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "We'd love to hear from you!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.softLavender,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),

              // Name Field
              TextFormField(
                controller: _nameController,
                validator: _validateName,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Name",
                  prefixIcon: Icon(Icons.person, color: Colors.white70),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // Email Field
              TextFormField(
                controller: _emailController,
                validator: _validateEmail,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email, color: Colors.white70),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // Message Field
              TextFormField(
                controller: _messageController,
                validator: _validateMessage,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Feedback Message",
                  prefixIcon: Icon(Icons.message, color: Colors.white70),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 40),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.darkBackground,
                        ),
                      )
                    : const Text("Submit Feedback"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
