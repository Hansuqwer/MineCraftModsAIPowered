import 'package:flutter/material.dart';

class CreationHistoryScreen extends StatefulWidget {
  const CreationHistoryScreen({super.key});

  @override
  State<CreationHistoryScreen> createState() => _CreationHistoryScreenState();
}

class _CreationHistoryScreenState extends State<CreationHistoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnimation;

  // Mock creation history data
  final List<Map<String, dynamic>> _creations = [
    {
      'name': 'Rainbow Cow',
      'type': 'Cow',
      'date': '2024-01-15',
      'time': '14:30',
      'attributes': 'rainbow colors with sparkles',
      'status': 'completed',
    },
    {
      'name': 'Pink Pig',
      'type': 'Pig',
      'date': '2024-01-14',
      'time': '16:45',
      'attributes': 'pink color with glows',
      'status': 'completed',
    },
    {
      'name': 'Blue Chicken',
      'type': 'Chicken',
      'date': '2024-01-13',
      'time': '10:20',
      'attributes': 'blue color that flies',
      'status': 'completed',
    },
    {
      'name': 'Golden Sheep',
      'type': 'Sheep',
      'date': '2024-01-12',
      'time': '15:10',
      'attributes': 'golden color with sparkles',
      'status': 'completed',
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Sparkle animation for celebration
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _sparkleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0), // Crafta cream background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7DC6F), // Crafta yellow
        title: const Text(
          'Creation History',
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
            // Header with celebration animation
            AnimatedBuilder(
              animation: _sparkleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _sparkleAnimation.value,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7DC6F), // Crafta yellow
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF7DC6F).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 48,
                          color: Colors.white,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Your Child\'s Creations',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'See all the amazing creatures they\'ve created!',
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
            
            // Creations List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _creations.length,
                itemBuilder: (context, index) {
                  final creation = _creations[index];
                  return _buildCreationCard(creation, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreationCard(Map<String, dynamic> creation, int index) {
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
              // Creation icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF98D8C8), // Crafta mint
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              
              // Creation details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      creation['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'A ${creation['type']} with ${creation['attributes']}',
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
                          '${creation['date']} at ${creation['time']}',
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
                  'Completed',
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
                    // TODO: View creation details
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Viewing ${creation['name']} details'),
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
                    // TODO: Download creation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Downloading ${creation['name']}'),
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

