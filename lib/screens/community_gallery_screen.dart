import 'package:flutter/material.dart';
import '../services/community_service.dart';
import '../services/google_cloud_service.dart';
import '../theme/enhanced_modern_theme.dart';
// import '../widgets/minecraft_button.dart';
// import '../widgets/minecraft_text.dart';
// import '../widgets/minecraft_panel.dart';

/// Community Gallery Screen
/// Browse, share, and interact with community creations
class CommunityGalleryScreen extends StatefulWidget {
  const CommunityGalleryScreen({super.key});

  @override
  State<CommunityGalleryScreen> createState() => _CommunityGalleryScreenState();
}

class _CommunityGalleryScreenState extends State<CommunityGalleryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // State
  List<CommunityCreation> _featuredCreations = [];
  List<CommunityCreation> _trendingCreations = [];
  List<CommunityCreation> _recentCreations = [];
  List<CommunityCreation> _userFavorites = [];
  List<CommunityCreation> _userDownloads = [];
  CommunityUserStats _userStats = CommunityUserStats.empty();
  
  bool _isLoading = true;
  String _searchQuery = '';
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fadeController = AnimationController(
      duration: EnhancedModernTheme.animationMedium,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: EnhancedModernTheme.curveEaseOut),
    );
    
    _loadCommunityData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadCommunityData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        CommunityService.getFeaturedCreations(),
        CommunityService.getTrendingCreations(),
        CommunityService.getRecentCreations(),
        CommunityService.getUserFavorites(),
        CommunityService.getUserDownloads(),
        CommunityService.getUserStats(),
      ]);

      setState(() {
        _featuredCreations = results[0] as List<CommunityCreation>;
        _trendingCreations = results[1] as List<CommunityCreation>;
        _recentCreations = results[2] as List<CommunityCreation>;
        _userFavorites = results[3] as List<CommunityCreation>;
        _userDownloads = results[4] as List<CommunityCreation>;
        _userStats = results[5] as CommunityUserStats;
        _isLoading = false;
      });

      _fadeController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load community data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EnhancedModernTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Community Gallery'),
        backgroundColor: EnhancedModernTheme.surfaceLight,
        foregroundColor: EnhancedModernTheme.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCommunityData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Featured', icon: Icon(Icons.star)),
            Tab(text: 'Trending', icon: Icon(Icons.trending_up)),
            Tab(text: 'Recent', icon: Icon(Icons.schedule)),
            Tab(text: 'Favorites', icon: Icon(Icons.favorite)),
            Tab(text: 'Downloads', icon: Icon(Icons.download)),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildFeaturedTab(),
                  _buildTrendingTab(),
                  _buildRecentTab(),
                  _buildFavoritesTab(),
                  _buildDownloadsTab(),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showShareDialog,
        icon: const Icon(Icons.share),
        label: const Text('Share Creation'),
        backgroundColor: EnhancedModernTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildFeaturedTab() {
    return _buildCreationsList(_featuredCreations, 'No featured creations yet');
  }

  Widget _buildTrendingTab() {
    return _buildCreationsList(_trendingCreations, 'No trending creations yet');
  }

  Widget _buildRecentTab() {
    return _buildCreationsList(_recentCreations, 'No recent creations yet');
  }

  Widget _buildFavoritesTab() {
    return _buildCreationsList(_userFavorites, 'No favorites yet');
  }

  Widget _buildDownloadsTab() {
    return _buildCreationsList(_userDownloads, 'No downloads yet');
  }

  Widget _buildCreationsList(List<CommunityCreation> creations, String emptyMessage) {
    if (creations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_off,
              size: 64,
              color: EnhancedModernTheme.textSecondary,
            ),
            const SizedBox(height: EnhancedModernTheme.spacingMedium),
            Text(
              emptyMessage,
              style: EnhancedModernTheme.bodyLarge.copyWith(
                color: EnhancedModernTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCommunityData,
      child: ListView.builder(
        padding: const EdgeInsets.all(EnhancedModernTheme.spacingMedium),
        itemCount: creations.length,
        itemBuilder: (context, index) {
          final creation = creations[index];
          return _buildCreationCard(creation);
        },
      ),
    );
  }

  Widget _buildCreationCard(CommunityCreation creation) {
    return Container(
      margin: const EdgeInsets.only(bottom: EnhancedModernTheme.spacingMedium),
      decoration: EnhancedModernTheme.modernCard(
        shadows: EnhancedModernTheme.mediumShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with author info
          Padding(
            padding: const EdgeInsets.all(EnhancedModernTheme.spacingMedium),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: creation.authorPhoto != null
                      ? NetworkImage(creation.authorPhoto!)
                      : null,
                  child: creation.authorPhoto == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: EnhancedModernTheme.spacingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        creation.authorName,
                        style: EnhancedModernTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatDate(creation.createdAt),
                        style: EnhancedModernTheme.bodySmall.copyWith(
                          color: EnhancedModernTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (creation.featured)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: EnhancedModernTheme.spacingSmall,
                      vertical: EnhancedModernTheme.spacingXSmall,
                    ),
                    decoration: BoxDecoration(
                      color: EnhancedModernTheme.warningOrange,
                      borderRadius: BorderRadius.circular(EnhancedModernTheme.radiusSmall),
                    ),
                    child: Text(
                      'FEATURED',
                      style: EnhancedModernTheme.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Creation preview (placeholder for 3D preview)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: EnhancedModernTheme.surfaceDark,
              borderRadius: BorderRadius.circular(EnhancedModernTheme.radiusMedium),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.view_in_ar,
                    size: 48,
                    color: EnhancedModernTheme.textSecondary,
                  ),
                  const SizedBox(height: EnhancedModernTheme.spacingSmall),
                  Text(
                    '3D Preview',
                    style: EnhancedModernTheme.bodyMedium.copyWith(
                      color: EnhancedModernTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(EnhancedModernTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  creation.title,
                  style: EnhancedModernTheme.heading3,
                ),
                const SizedBox(height: EnhancedModernTheme.spacingSmall),
                Text(
                  creation.description,
                  style: EnhancedModernTheme.bodyMedium.copyWith(
                    color: EnhancedModernTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: EnhancedModernTheme.spacingSmall),
                
                // Tags
                if (creation.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: EnhancedModernTheme.spacingXSmall,
                    children: creation.tags.map((tag) => 
                      EnhancedModernTheme.modernChip(
                        label: tag,
                        backgroundColor: EnhancedModernTheme.primaryBlueLight,
                      ),
                    ).toList(),
                  ),
                  const SizedBox(height: EnhancedModernTheme.spacingMedium),
                ],

                // Stats and actions
                Row(
                  children: [
                    _buildStatButton(
                      icon: Icons.favorite,
                      count: creation.likes,
                      onTap: () => _likeCreation(creation.id),
                    ),
                    const SizedBox(width: EnhancedModernTheme.spacingSmall),
                    _buildStatButton(
                      icon: Icons.download,
                      count: creation.downloads,
                      onTap: () => _downloadCreation(creation.id),
                    ),
                    const SizedBox(width: EnhancedModernTheme.spacingSmall),
                    _buildStatButton(
                      icon: Icons.visibility,
                      count: creation.views,
                      onTap: () {},
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () => _toggleFavorite(creation.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () => _shareCreation(creation),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatButton({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: EnhancedModernTheme.spacingSmall,
          vertical: EnhancedModernTheme.spacingXSmall,
        ),
        decoration: BoxDecoration(
          color: EnhancedModernTheme.surfaceLight,
          borderRadius: BorderRadius.circular(EnhancedModernTheme.radiusSmall),
          border: Border.all(color: EnhancedModernTheme.textHint),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: EnhancedModernTheme.textSecondary),
            const SizedBox(width: EnhancedModernTheme.spacingXSmall),
            Text(
              count.toString(),
              style: EnhancedModernTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _likeCreation(String creationId) async {
    final result = await CommunityService.likeCreation(creationId);
    if (result.success) {
      _showSuccessSnackBar(result.message ?? 'Liked!');
      _loadCommunityData();
    } else {
      _showErrorSnackBar(result.error ?? 'Failed to like');
    }
  }

  Future<void> _downloadCreation(String creationId) async {
    final result = await CommunityService.downloadCreation(creationId);
    if (result.success) {
      _showSuccessSnackBar(result.message ?? 'Downloaded!');
      _loadCommunityData();
    } else {
      _showErrorSnackBar(result.error ?? 'Failed to download');
    }
  }

  Future<void> _toggleFavorite(String creationId) async {
    final isFavorited = _userFavorites.any((c) => c.id == creationId);
    
    final result = isFavorited
        ? await CommunityService.removeFromFavorites(creationId)
        : await CommunityService.addToFavorites(creationId);
    
    if (result.success) {
      _showSuccessSnackBar(result.message ?? 'Updated!');
      _loadCommunityData();
    } else {
      _showErrorSnackBar(result.error ?? 'Failed to update');
    }
  }

  void _shareCreation(CommunityCreation creation) {
    // Implement sharing logic
    _showSuccessSnackBar('Shared ${creation.title}');
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Creations'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search by title, description, or tags',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: EnhancedModernTheme.spacingMedium),
            const Text('Popular Tags:'),
            const SizedBox(height: EnhancedModernTheme.spacingSmall),
            Wrap(
              spacing: EnhancedModernTheme.spacingXSmall,
              children: ['dragon', 'sword', 'armor', 'furniture', 'vehicle'].map((tag) =>
                EnhancedModernTheme.modernChip(
                  label: tag,
                  onDeleted: _selectedTags.contains(tag) ? () {
                    setState(() {
                      _selectedTags.remove(tag);
                    });
                  } : null,
                ),
              ).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performSearch();
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _performSearch() {
    // Implement search logic
    _showSuccessSnackBar('Searching for: $_searchQuery');
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Your Creation'),
        content: const Text('Select a creation from your library to share with the community.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to user's creations
            },
            child: const Text('My Creations'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      EnhancedModernTheme.modernSnackBar(
        message: message,
        backgroundColor: EnhancedModernTheme.successGreen,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      EnhancedModernTheme.modernSnackBar(
        message: message,
        backgroundColor: EnhancedModernTheme.errorRed,
      ),
    );
  }
}
