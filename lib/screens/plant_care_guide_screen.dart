import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/plant.dart';
import '../services/plant_service.dart';

class PlantCareGuideScreen extends StatefulWidget {
  final Plant plant;

  const PlantCareGuideScreen({super.key, required this.plant});

  @override
  State<PlantCareGuideScreen> createState() => _PlantCareGuideScreenState();
}

class _PlantCareGuideScreenState extends State<PlantCareGuideScreen> {
  Map<String, String> _careGuide = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCareGuide();
  }

  Future<void> _loadCareGuide() async {
    setState(() => _isLoading = true);
    try {
      final guide = PlantService.getPlantCareGuide(widget.plant.name);
      setState(() {
        _careGuide = guide;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B4FCF),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        title: Text(
          'Care Guidelines',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF5B4FCF)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plant Info Header
                  Container(
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
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5B4FCF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.local_florist_rounded,
                            color: Color(0xFF5B4FCF),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.plant.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[900],
                                ),
                              ),
                              Text(
                                'Complete care guide',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Care Guide Items
                  ..._careGuide.entries.map((entry) {
                    return _buildCareGuideItem(
                      title: _formatCareTitle(entry.key),
                      content: entry.value,
                      icon: _getCareIcon(entry.key),
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildCareGuideItem({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4CAF50),
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[900],
            ),
          ),
          children: [
            Text(
              content,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCareTitle(String key) {
    switch (key) {
      case 'watering':
        return 'Watering';
      case 'sunlight':
        return 'Sunlight';
      case 'temperature':
        return 'Temperature';
      case 'soil':
        return 'Soil';
      case 'fertilizing':
        return 'Fertilizing';
      case 'pruning':
        return 'Pruning';
      case 'common_issues':
        return 'Common Issues';
      default:
        return key.replaceAll('_', ' ').toUpperCase();
    }
  }

  IconData _getCareIcon(String key) {
    switch (key) {
      case 'watering':
        return Icons.water_drop_rounded;
      case 'sunlight':
        return Icons.wb_sunny_rounded;
      case 'temperature':
        return Icons.thermostat_rounded;
      case 'soil':
        return Icons.landscape_rounded;
      case 'fertilizing':
        return Icons.eco_rounded;
      case 'pruning':
        return Icons.content_cut_rounded;
      case 'common_issues':
        return Icons.bug_report_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }
}