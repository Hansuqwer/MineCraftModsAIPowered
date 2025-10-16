import 'package:flutter/material.dart';

class ExportManagementScreen extends StatefulWidget {
  const ExportManagementScreen({super.key});

  @override
  State<ExportManagementScreen> createState() => _ExportManagementScreenState();
}

class _ExportManagementScreenState extends State<ExportManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _downloadController;
  late Animation<double> _downloadAnimation;

  // Mock export data
  final List<Map<String, dynamic>> _exports = [
    {
      'name': 'Rainbow Cow Mod',
      'size': '2.3 MB',
      'date': '2024-01-15',
      'status': 'ready',
      'downloads': 3,
    },
    {
      'name': 'Pink Pig Mod',
      'size': '1.8 MB',
      'date': '2024-01-14',
      'status': 'ready',
      'downloads': 1,
    },
    {
      'name': 'Blue Chicken Mod',
      'size': '2.1 MB',
      'date': '2024-01-13',
      'status': 'ready',
      'downloads': 2,
    },
    {
      'name': 'Golden Sheep Mod',
      'size': '1.9 MB',
      'date': '2024-01-12',
      'status': 'ready',
      'downloads': 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Download animation
    _downloadController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _downloadAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _downloadController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _downloadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0), // Crafta cream background
      appBar: AppBar(
        backgroundColor: const Color(0xFF98D8C8), // Crafta mint
        title: const Text(
          'Export Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header with download animation
            AnimatedBuilder(
              animation: _downloadAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _downloadAnimation.value,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF98D8C8), // Crafta mint
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF98D8C8).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.file_download,
                          size: 48,
                          color: Colors.white,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Export Management',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Manage your child\'s mod downloads',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            // Export List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _exports.length,
                itemBuilder: (context, index) {
                  final export = _exports[index];
                  return _buildExportCard(export, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportCard(Map<String, dynamic> export, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Export icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7DC6F), // Crafta yellow
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.file_download,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              
              // Export details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      export['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Size: ${export['size']} • Downloads: ${export['downloads']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: const Color(0xFF98D8C8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Created: ${export['date']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF98D8C8), // Crafta mint
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Ready',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: View export details
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Viewing ${export['name']} details'),
                        backgroundColor: const Color(0xFF98D8C8),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF98D8C8),
                    side: const BorderSide(color: Color(0xFF98D8C8), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Download export
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Downloading ${export['name']}'),
                        backgroundColor: const Color(0xFFF7DC6F),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7DC6F), // Crafta yellow
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Download',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

