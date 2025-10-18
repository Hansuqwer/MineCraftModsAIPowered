import 'package:flutter/material.dart';
import '../services/multiplayer_service.dart';
import '../models/enhanced_creature_attributes.dart';
import '../theme/minecraft_theme.dart';

/// Multiplayer Collaborative Creation Screen
class MultiplayerScreen extends StatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<MultiplayerSession> _sessions = [];
  bool _isLoading = false;
  String _participantName = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSessions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    try {
      final sessions = await MultiplayerService.getActiveSessions();
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinecraftTheme.darkBlue,
      appBar: AppBar(
        title: const Text(
          'MULTIPLAYER',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: MinecraftTheme.darkBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: MinecraftTheme.diamond,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'JOIN SESSION'),
            Tab(text: 'CREATE SESSION'),
            Tab(text: 'MY SESSIONS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJoinSessionTab(),
          _buildCreateSessionTab(),
          _buildMySessionsTab(),
        ],
      ),
    );
  }

  Widget _buildJoinSessionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildParticipantNameInput(),
          const SizedBox(height: 24),
          _buildSessionList(),
        ],
      ),
    );
  }

  Widget _buildCreateSessionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCreateSessionForm(),
        ],
      ),
    );
  }

  Widget _buildMySessionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMySessionsList(),
        ],
      ),
    );
  }

  Widget _buildParticipantNameInput() {
    return MinecraftPanel(
      backgroundColor: MinecraftTheme.deepStone.withOpacity(0.8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MinecraftText(
            'YOUR NAME',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: MinecraftTheme.goldOre,
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) => _participantName = value,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              hintStyle: const TextStyle(color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: MinecraftTheme.diamond),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: MinecraftTheme.diamond),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: MinecraftTheme.diamond, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (_sessions.isEmpty) {
      return MinecraftPanel(
        backgroundColor: MinecraftTheme.deepStone.withOpacity(0.8),
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: MinecraftText(
            'No active sessions found',
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      );
    }

    return Column(
      children: _sessions.map((session) => _buildSessionCard(session)).toList(),
    );
  }

  Widget _buildSessionCard(MultiplayerSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: MinecraftPanel(
        backgroundColor: MinecraftTheme.deepStone.withOpacity(0.8),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: MinecraftText(
                    session.name,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: MinecraftTheme.diamond,
                  ),
                ),
                MinecraftText(
                  '${session.participants.length} players',
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ],
            ),
            const SizedBox(height: 8),
            MinecraftText(
              'Host: ${session.hostName}',
              fontSize: 14,
              color: Colors.white70,
            ),
            const SizedBox(height: 4),
            MinecraftText(
              'Created: ${_formatDateTime(session.createdAt)}',
              fontSize: 12,
              color: Colors.white54,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MinecraftButton(
                    text: 'JOIN',
                    onPressed: () => _joinSession(session),
                    color: MinecraftTheme.emerald,
                    icon: Icons.group_add,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 12),
                MinecraftButton(
                  text: 'VIEW',
                  onPressed: () => _viewSession(session),
                  color: MinecraftTheme.diamond,
                  icon: Icons.visibility,
                  height: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateSessionForm() {
    final sessionNameController = TextEditingController();
    final hostNameController = TextEditingController();

    return MinecraftPanel(
      backgroundColor: MinecraftTheme.deepStone.withOpacity(0.8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MinecraftText(
            'CREATE NEW SESSION',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MinecraftTheme.goldOre,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: sessionNameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Session Name',
              labelStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: MinecraftTheme.diamond),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: MinecraftTheme.diamond),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: MinecraftTheme.diamond, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: hostNameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Your Name',
              labelStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: MinecraftTheme.diamond),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: MinecraftTheme.diamond),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: MinecraftTheme.diamond, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          MinecraftButton(
            text: 'CREATE SESSION',
            onPressed: () => _createSession(
              sessionNameController.text,
              hostNameController.text,
            ),
            color: MinecraftTheme.emerald,
            icon: Icons.add,
            height: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildMySessionsList() {
    return FutureBuilder<List<MultiplayerSession>>(
      future: MultiplayerService.getSessionHistory(_participantName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return MinecraftPanel(
            backgroundColor: MinecraftTheme.deepStone.withOpacity(0.8),
            padding: const EdgeInsets.all(24),
            child: const Center(
              child: MinecraftText(
                'No sessions found',
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          );
        }

        return Column(
          children: snapshot.data!.map((session) => _buildMySessionCard(session)).toList(),
        );
      },
    );
  }

  Widget _buildMySessionCard(MultiplayerSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: MinecraftPanel(
        backgroundColor: session.isActive 
            ? MinecraftTheme.emerald.withOpacity(0.2)
            : MinecraftTheme.deepStone.withOpacity(0.8),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: MinecraftText(
                    session.name,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: session.isActive ? MinecraftTheme.emerald : Colors.white70,
                  ),
                ),
                if (session.isActive)
                  const MinecraftText(
                    'ACTIVE',
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  )
                else
                  const MinecraftText(
                    'ENDED',
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            MinecraftText(
              'Host: ${session.hostName}',
              fontSize: 14,
              color: Colors.white70,
            ),
            const SizedBox(height: 4),
            MinecraftText(
              'Participants: ${session.participants.length}',
              fontSize: 14,
              color: Colors.white70,
            ),
            const SizedBox(height: 4),
            MinecraftText(
              'Contributions: ${session.contributions.length}',
              fontSize: 14,
              color: Colors.white70,
            ),
            const SizedBox(height: 12),
            if (session.isActive)
              Row(
                children: [
                  Expanded(
                    child: MinecraftButton(
                      text: 'REJOIN',
                      onPressed: () => _joinSession(session),
                      color: MinecraftTheme.emerald,
                      icon: Icons.group_add,
                      height: 40,
                    ),
                  ),
                  const SizedBox(width: 12),
                  MinecraftButton(
                    text: 'END',
                    onPressed: () => _endSession(session),
                    color: Colors.red,
                    icon: Icons.stop,
                    height: 40,
                  ),
                ],
              )
            else
              MinecraftButton(
                text: 'VIEW DETAILS',
                onPressed: () => _viewSession(session),
                color: MinecraftTheme.diamond,
                icon: Icons.visibility,
                height: 40,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _joinSession(MultiplayerSession session) async {
    if (_participantName.isEmpty) {
      _showSnackBar('Please enter your name first');
      return;
    }

    final success = await MultiplayerService.joinSession(session.id, _participantName);
    if (success) {
      _showSnackBar('Joined session successfully!');
      _loadSessions();
    } else {
      _showSnackBar('Failed to join session');
    }
  }

  Future<void> _createSession(String sessionName, String hostName) async {
    if (sessionName.isEmpty || hostName.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    // Create a basic creature for the session
    final initialCreature = EnhancedCreatureAttributes(
      baseType: 'Dragon',
      primaryColor: Colors.red,
      secondaryColor: Colors.orange,
      accentColor: Colors.yellow,
      size: CreatureSize.large,
      abilities: [SpecialAbility.flying],
      accessories: [],
      personality: PersonalityType.friendly,
      patterns: [],
      texture: TextureType.smooth,
      glowEffect: GlowEffect.none,
      animationStyle: CreatureAnimationStyle.natural,
      customName: 'Collaborative Dragon',
      description: 'A dragon created together!',
    );

    final session = await MultiplayerService.createSession(
      sessionName: sessionName,
      hostName: hostName,
      initialCreature: initialCreature,
    );

    _showSnackBar('Session created successfully!');
    _loadSessions();
  }

  Future<void> _viewSession(MultiplayerSession session) async {
    // Navigate to session details screen
    // This would show the current creature and all contributions
  }

  Future<void> _endSession(MultiplayerSession session) async {
    final success = await MultiplayerService.endSession(session.id);
    if (success) {
      _showSnackBar('Session ended');
      _loadSessions();
    } else {
      _showSnackBar('Failed to end session');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: MinecraftTheme.diamond,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Minecraft-style button widget
class MinecraftButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final IconData? icon;
  final double? height;

  const MinecraftButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
