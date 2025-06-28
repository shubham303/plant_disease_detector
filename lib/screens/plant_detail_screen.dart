import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/plant.dart';
import '../utils/navigation_utils.dart';
import '../widgets/plant_scan_widget.dart';
import 'plant_care_guide_screen.dart';
import 'plant_care_history_screen.dart';
import 'plant_scan_history_screen.dart';

class PlantDetailScreen extends StatefulWidget {
  final Plant plant;

  const PlantDetailScreen({super.key, required this.plant});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  late Plant _currentPlant;
  String? _analysisResult;

  @override
  void initState() {
    super.initState();
    _currentPlant = widget.plant;
  }

  void _openCareGuide() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlantCareGuideScreen(plant: _currentPlant),
      ),
    );
  }


  void _openCareHistory() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlantCareHistoryScreen(plant: _currentPlant),
      ),
    );
    
    // Update plant if history was modified
    if (result != null && result is Plant) {
      setState(() {
        _currentPlant = result;
      });
    }
  }

  void _openScanHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlantScanHistoryScreen(plant: _currentPlant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0), // Yellowish white background
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF5B4FCF),
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'plant-${_currentPlant.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _currentPlant.imagePaths.isNotEmpty
                        ? _buildImageCarousel()
                        : _buildPlantPlaceholder(),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              title: Text(
                _currentPlant.name,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Plant Info Card
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5B4FCF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: Color(0xFF5B4FCF),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Added ${_formatDate(_currentPlant.dateAdded)}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (_currentPlant.notes != null &&
                                _currentPlant.notes!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                _currentPlant.notes!,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00ACC1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            NavigationUtils.openPlantChat(context, _currentPlant);
                          },
                          child: const Icon(
                            Icons.chat_bubble_outline,
                            color: Color(0xFF00ACC1),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Plant Scanner Section (Always visible at top)
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00ACC1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.qr_code_scanner,
                              color: Color(0xFF00ACC1),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Plant Health Scanner',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      PlantScanWidget(
                        plantType: _currentPlant.plantType,
                        title: '',
                        onAnalysisComplete: (result) {
                          setState(() {
                            _analysisResult = result;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                
                // Navigation Options
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildNavigationItem(
                        icon: Icons.menu_book_rounded,
                        title: 'Care Guidelines',
                        subtitle: 'View detailed care instructions',
                        color: const Color(0xFF4CAF50),
                        onTap: _openCareGuide,
                      ),
                      _buildDivider(),
                      _buildNavigationItem(
                        icon: Icons.history_rounded,
                        title: 'Care History',
                        subtitle: 'Track your plant care activities',
                        color: const Color(0xFFFF8F00),
                        onTap: _openCareHistory,
                      ),
                      _buildDivider(),
                      _buildNavigationItem(
                        icon: Icons.qr_code_scanner_rounded,
                        title: 'Scan History',
                        subtitle: 'View past disease scan results',
                        color: const Color(0xFF00ACC1),
                        onTap: _openScanHistory,
                      ),
                    ],
                  ),
                ),
                
                // Analysis Result Section
                if (_analysisResult != null) ...[  
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.95),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5B4FCF).withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF5B4FCF).withOpacity(0.08),
                                const Color(0xFF7C6FE8).withOpacity(0.05),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF5B4FCF), Color(0xFF7C6FE8)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.eco_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Analysis Complete',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            size: 12,
                                            color: Color(0xFF4CAF50),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'AI Powered',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF4CAF50),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Content
                        Container(
                          constraints: const BoxConstraints(maxHeight: 300),
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFBFF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF5B4FCF).withOpacity(0.1),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Markdown(
                              data: _analysisResult!,
                              padding: const EdgeInsets.all(20),
                              styleSheet: MarkdownStyleSheet(
                                h1: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF5B4FCF),
                                ),
                                h2: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2C2C2C),
                                ),
                                h3: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF424242),
                                ),
                                p: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF5A5A5A),
                                  height: 1.6,
                                ),
                                strong: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2C2C2C),
                                ),
                                listBullet: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF5B4FCF),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Actions
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _analysisResult = null;
                                    });
                                  },
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: Text(
                                    'New Scan',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF5B4FCF),
                                    side: BorderSide(
                                      color: const Color(0xFF5B4FCF).withOpacity(0.3),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 80), // Space for FAB
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5B4FCF), Color(0xFF7C6FE8)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B4FCF).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: "plant_chat_fab",
          onPressed: () {
            NavigationUtils.openPlantChat(context, _currentPlant);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          child: const Icon(Icons.chat_bubble_rounded),
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    if (_currentPlant.imagePaths.length == 1) {
      // Single image
      final imagePath = _currentPlant.imagePaths.first;
      return kIsWeb
          ? Image.network(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) => _buildPlantPlaceholder(),
            )
          : (File(imagePath).existsSync()
              ? Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
              : _buildPlantPlaceholder());
    } else {
      // Multiple images with PageView
      return Stack(
        children: [
          PageView.builder(
            itemCount: _currentPlant.imagePaths.length,
            itemBuilder: (context, index) {
              final imagePath = _currentPlant.imagePaths[index];
              return kIsWeb
                  ? Image.network(
                      imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => _buildPlantPlaceholder(),
                    )
                  : (File(imagePath).existsSync()
                      ? Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : _buildPlantPlaceholder());
            },
          ),
          // Image counter indicator
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentPlant.imagePaths.length} photos',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Swipe indicator dots
          if (_currentPlant.imagePaths.length > 1)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _currentPlant.imagePaths.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }
  }

  Widget _buildPlantPlaceholder() {
    return Container(
      color: const Color(0xFF5B4FCF).withOpacity(0.1),
      child: const Center(
        child: Icon(
          Icons.local_florist_rounded,
          size: 80,
          color: Color(0xFF5B4FCF),
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
              const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey[400],
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: Colors.grey[200],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    }
  }
}