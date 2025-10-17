import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/terms_of_service.dart';
import '../widgets/legal_disclaimer.dart';

/// Legal settings screen for terms, privacy, and content guidelines
class LegalSettingsScreen extends StatefulWidget {
  const LegalSettingsScreen({super.key});

  @override
  State<LegalSettingsScreen> createState() => _LegalSettingsScreenState();
}

class _LegalSettingsScreenState extends State<LegalSettingsScreen> {
  bool _hasAcceptedTerms = false;
  bool _hasAcceptedPrivacy = false;
  bool _hasAcceptedGuidelines = false;

  @override
  void initState() {
    super.initState();
    _loadLegalStatus();
  }

  void _loadLegalStatus() {
    setState(() {
      _hasAcceptedTerms = TermsOfService.hasAcceptedTerms();
      _hasAcceptedPrivacy = true; // Placeholder
      _hasAcceptedGuidelines = true; // Placeholder
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal & Privacy'),
        backgroundColor: const Color(0xFF98D8C8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Legal disclaimer
            const FullLegalDisclaimer(),
            
            const SizedBox(height: 24),
            
            // Terms of Service
            _buildLegalSection(
              'Terms of Service',
              'Read our terms and conditions',
              Icons.description,
              () => _showTermsDialog(),
            ),
            
            const SizedBox(height: 16),
            
            // Privacy Policy
            _buildLegalSection(
              'Privacy Policy',
              'How we handle your data',
              Icons.privacy_tip,
              () => _showPrivacyDialog(),
            ),
            
            const SizedBox(height: 16),
            
            // Content Guidelines
            _buildLegalSection(
              'Content Guidelines',
              'Rules for creating content',
              Icons.rule,
              () => _showGuidelinesDialog(),
            ),
            
            const SizedBox(height: 24),
            
            // Minecraft EULA Compliance
            _buildComplianceSection(),
            
            const SizedBox(height: 24),
            
            // Legal Status
            _buildLegalStatusSection(),
            
            const SizedBox(height: 24),
            
            // Contact Information
            _buildContactSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalSection(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF98D8C8)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildComplianceSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Text(
                  'Minecraft EULA Compliance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildComplianceItem('✅ Original Content', 'All generated content is original'),
            _buildComplianceItem('✅ No Mojang Assets', 'No copyrighted Mojang content included'),
            _buildComplianceItem('✅ Community Standards', 'Complies with Minecraft Community Standards'),
            _buildComplianceItem('✅ Educational Focus', 'Positioned as learning tool'),
            _buildComplianceItem('✅ Legal Disclaimers', 'Clear non-affiliation statements'),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalStatusSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  'Legal Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusItem('Terms of Service', _hasAcceptedTerms),
            _buildStatusItem('Privacy Policy', _hasAcceptedPrivacy),
            _buildStatusItem('Content Guidelines', _hasAcceptedGuidelines),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String title, bool accepted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            accepted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: accepted ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.contact_support, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildContactItem('Legal Questions', 'legal@crafta.app'),
            _buildContactItem('Privacy Questions', 'privacy@crafta.app'),
            _buildContactItem('General Support', 'support@crafta.app'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(String title, String email) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Text(TermsOfService.getTermsOfService()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _acceptTerms();
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Text(TermsOfService.getPrivacyPolicy()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showGuidelinesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Content Guidelines'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Text(TermsOfService.getContentGuidelines()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _acceptTerms() async {
    await TermsOfService.acceptTerms();
    setState(() {
      _hasAcceptedTerms = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terms of Service accepted'),
        backgroundColor: Colors.green,
      ),
    );
  }
}


