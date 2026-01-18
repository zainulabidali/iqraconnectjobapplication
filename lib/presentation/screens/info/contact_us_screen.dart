import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(launchUri)) {
      debugPrint("Could not launch $launchUri");
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (!await launchUrl(launchUri)) {
      debugPrint("Could not launch $launchUri");
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    // Basic whatsapp url, can be enhanced with text
    final url = "https://wa.me/$phone";
    _launchUrl(url);
  }

  // Helper to build contact cards
  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return Card(
      elevation: 4,
      color: AppTheme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: AppTheme.darkBackground,
          radius: 24,
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.white54,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text("Contact Us"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Header Text (Optional)
            const Text(
              "Get in touch with us!",
              style: TextStyle(
                color: AppTheme.softLavender,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            // Phone
            _buildContactCard(
              icon: Icons.phone,
              title: "Phone Number",
              subtitle: "+91 9207000000", // Replace with actual number
              iconColor: Colors.greenAccent,
              onTap: () => _makePhoneCall("+919207846064"),
            ),

            // Email
            _buildContactCard(
              icon: Icons.email,
              title: "Email",
              subtitle: "support@jobfinder.com", // Replace with actual email
              iconColor: Colors.orangeAccent,
              onTap: () => _sendEmail("jkjack203@gmail.com"),
            ),

            // WhatsApp
            _buildContactCard(
              icon: Icons
                  .chat, // Or proper whatsapp icon if available (using chat for now)
              title: "WhatsApp",
              subtitle: "Chat with us",
              iconColor: Colors.green,
              onTap: () => _openWhatsApp(
                "919207846064",
              ), // Replace with actual wa number
            ),

            // Address
            // _buildContactCard(
            //   icon: Icons.location_on,
            //   title: "Address",
            //   subtitle:
            //       "123 Job Street, Tech City, India", // Replace with actual address
            //   iconColor: Colors.redAccent,
            //   onTap: () {
            //     // Optional: Open maps
            //     _launchUrl(
            //       "https://maps.google.com/?q=123+Job+Street,+Tech+City,+India",
            //     );
            //   },
            // ),
            const SizedBox(height: 40),
            const Text(
              "Follow us on Social Media",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 20),
            
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    IconButton(
      icon: const FaIcon(
        FontAwesomeIcons.facebook,
        color: Colors.blue,
      ),
      onPressed: () => _launchUrl(
        "https://www.facebook.com/profile.php?id=100087609451752",
      ),
    ),

    IconButton(
      icon: const FaIcon(
        FontAwesomeIcons.instagram,
        color: Color(0xFFE1306C),
      ),
      onPressed: () => _launchUrl(
        "https://www.instagram.com/zainul_abid_himami/",
      ),
    ),

    IconButton(
      icon: const FaIcon(
        FontAwesomeIcons.whatsapp,
        color: Color(0xFF25D366),
      ),
      onPressed: () => _launchUrl(
        "https://wa.me/919207846064",
      ),
    ),
  ],
)

          ],
        ),
      ),
    );
  }
}
