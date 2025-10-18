import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class AIProviderStatusScreen extends StatefulWidget {
  const AIProviderStatusScreen({super.key});

  @override
  State<AIProviderStatusScreen> createState() => _AIProviderStatusScreenState();
}

class _AIProviderStatusScreenState extends State<AIProviderStatusScreen> {
  Map<String, dynamic>? _providerStatus;

  @override
  void initState() {
    super.initState();
    _loadProviderStatus();
  }

  void _loadProviderStatus() {
    setState(() {
      _providerStatus = AIService.getProviderStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0), // Crafta cream background
      appBar: AppBar(
        backgroundColor: const Color(0xFF98D8C8), // Crafta mint
        title: const Text(
          'AI Provider Status',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadProviderStatus,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Provider Card
              Container(
                width: double.infinity,
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
                        Icon(
                          Icons.psychology,
                          color: const Color(0xFF98D8C8),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Current AI Provider',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_providerStatus != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF98D8C8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _providerStatus!['currentProvider'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF98D8C8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // All Providers List
              const Text(
                'All AI Providers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              
              const SizedBox(height: 12),
              
              if (_providerStatus != null)
                Expanded(
                  child: ListView.builder(
                    itemCount: (_providerStatus!['providers'] as List).length,
                    itemBuilder: (context, index) {
                      final provider = (_providerStatus!['providers'] as List)[index];
                      final isCurrent = provider['name'] == _providerStatus!['currentProvider'];
                      final isAvailable = provider['available'] as bool;
                      final failures = provider['failures'] as int;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: isCurrent 
                            ? Border.all(color: const Color(0xFF98D8C8), width: 2)
                            : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Status Icon
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isAvailable 
                                  ? (isCurrent ? const Color(0xFF98D8C8) : const Color(0xFF4CAF50))
                                  : const Color(0xFFF44336),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isAvailable 
                                  ? (isCurrent ? Icons.check_circle : Icons.check)
                                  : Icons.error,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Provider Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        provider['name'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isCurrent 
                                            ? const Color(0xFF98D8C8)
                                            : const Color(0xFF333333),
                                        ),
                                      ),
                                      if (isCurrent) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF98D8C8),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            'ACTIVE',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isAvailable 
                                      ? 'Ready to use'
                                      : 'Not configured',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isAvailable 
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFFF44336),
                                    ),
                                  ),
                                  if (failures > 0) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Failures: $failures',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFFF9800),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              
              // Refresh Button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  onPressed: _loadProviderStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF98D8C8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Refresh Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
