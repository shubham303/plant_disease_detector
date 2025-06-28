import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/plant_analysis_service.dart';

class PlantDetailsScreen extends StatefulWidget {
  final List<XFile> selectedImages;
  final List<File>? selectedFiles;

  const PlantDetailsScreen({
    super.key,
    required this.selectedImages,
    this.selectedFiles,
  });

  @override
  State<PlantDetailsScreen> createState() => _PlantDetailsScreenState();
}

class _PlantDetailsScreenState extends State<PlantDetailsScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  List<String> _plantsList = [];
  String? _selectedPlant;
  String? _analysisResult;
  bool _isLoading = false;
  bool _isLoadingPlants = true;

  @override
  void initState() {
    super.initState();
    _loadPlantsList();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadPlantsList() async {
    try {
      final String plantsData = await rootBundle.loadString('assets/plants.txt');
      final List<String> plants = plantsData
          .split('\n')
          .where((plant) => plant.trim().isNotEmpty)
          .map((plant) => plant.trim())
          .toList();
      
      setState(() {
        _plantsList = plants;
        _isLoadingPlants = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPlants = false;
      });
      _showErrorDialog('Failed to load plants list: $e');
    }
  }

  Future<void> _analyzeImages() async {
    if (_selectedPlant == null) {
      _showErrorDialog('Please select a plant type');
      return;
    }

    setState(() {
      _isLoading = true;
      _analysisResult = null;
    });

    try {
      final File? imageFile = !kIsWeb && widget.selectedFiles != null && widget.selectedFiles!.isNotEmpty 
          ? widget.selectedFiles!.first 
          : null;
      
      final String description = _descriptionController.text.trim();
      final String fullContext = 'Plant type: $_selectedPlant. Additional description: $description';

      final result = await PlantAnalysisService.analyzeImage(
        imageFile,
        plantName: _selectedPlant!,
        context: fullContext,
      );
      
      setState(() {
        _analysisResult = result;
      });
      
      // Don't automatically pop - let user see results on this page
    } catch (e) {
      _showErrorDialog('Failed to analyze image: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Color(0xFFE57373),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF757575),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0), // Yellowish white background
      body: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF5B4FCF),
                          size: 20,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Plant Analysis Details',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 56), // Balance for back button
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Combined Container with Image, Plant Type, and Additional Details
                        Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF5B4FCF).withOpacity(0.1),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image Preview Section
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    height: 200,
                                    child: Stack(
                                      children: [
                                        PageView.builder(
                                          itemCount: widget.selectedImages.length,
                                          itemBuilder: (context, index) {
                                            return kIsWeb
                                                ? Image.network(
                                                    widget.selectedImages[index].path,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) => Container(
                                                      color: const Color(0xFFEEEEEE),
                                                      child: const Icon(
                                                        Icons.image_not_supported,
                                                        color: Color(0xFFBDBDBD),
                                                        size: 50,
                                                      ),
                                                    ),
                                                  )
                                                : widget.selectedFiles != null && index < widget.selectedFiles!.length
                                                    ? Image.file(
                                                        widget.selectedFiles![index],
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Container(
                                                        color: const Color(0xFFEEEEEE),
                                                        child: const Icon(
                                                          Icons.image_not_supported,
                                                          color: Color(0xFFBDBDBD),
                                                          size: 50,
                                                        ),
                                                      );
                                          },
                                        ),
                                        // Image count badge
                                        if (widget.selectedImages.length > 1)
                                          Positioned(
                                            bottom: 16,
                                            right: 16,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.7),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                '${widget.selectedImages.length} images',
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Form Fields Section
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Plant Type Section
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF5B4FCF).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.local_florist_rounded,
                                            color: Color(0xFF5B4FCF),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Plant Type',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF424242),
                                          ),
                                        ),
                                        Text(
                                          ' *',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFFE57373),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _isLoadingPlants
                                        ? const Center(
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B4FCF)),
                                            ),
                                          )
                                        : DropdownButtonFormField<String>(
                            value: _selectedPlant,
                            decoration: InputDecoration(
                              hintText: 'Select your plant type',
                              hintStyle: GoogleFonts.inter(
                                color: const Color(0xFF9E9E9E),
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF5F7FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: const Color(0xFF5B4FCF).withOpacity(0.1),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: const Color(0xFF5B4FCF).withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            dropdownColor: Colors.white,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF757575),
                            ),
                            isExpanded: true,
                            items: _plantsList.map((plant) {
                              return DropdownMenuItem<String>(
                                value: plant,
                                child: Text(
                                  plant,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF424242),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPlant = value;
                              });
                            },
                                          ),
                                    
                                    const SizedBox(height: 24),
                                    
                                    // Divider
                                    Container(
                                      height: 1,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            const Color(0xFF5B4FCF).withOpacity(0.1),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 24),
                                    
                                    // Additional Details Section
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF5B4FCF).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.description_rounded,
                                            color: Color(0xFF5B4FCF),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Additional Details',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF424242),
                                          ),
                                        ),
                                        Text(
                                          ' (Optional)',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: const Color(0xFF757575),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _descriptionController,
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                        hintText: 'Describe any symptoms, concerns, or specific questions about your plant...',
                                        hintStyle: GoogleFonts.inter(
                                          color: const Color(0xFF9E9E9E),
                                          fontSize: 14,
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFFF5F7FA),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: const Color(0xFF5B4FCF).withOpacity(0.1),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: const Color(0xFF5B4FCF).withOpacity(0.3),
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.all(16),
                                      ),
                                      style: GoogleFonts.inter(fontSize: 14),
                                    ),
                                    
                                    const SizedBox(height: 24),
                                    
                                    // Analyze Button
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      height: 56,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: _isLoading
                                              ? [const Color(0xFF7C6FE8), const Color(0xFF9C88FF)]
                                              : [const Color(0xFF5B4FCF), const Color(0xFF7C6FE8)],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF5B4FCF).withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: _isLoading ? null : _analyzeImages,
                                          borderRadius: BorderRadius.circular(16),
                                          child: Center(
                                            child: _isLoading
                                                ? Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      const SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2.5,
                                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        'Analyzing...',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      const Icon(
                                                        Icons.eco_rounded,
                                                        color: Colors.white,
                                                        size: 24,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        'Analyze Plant',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
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
                        
                        // Analysis Result
                        if (_analysisResult != null) ...[
                          const SizedBox(height: 24),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF5B4FCF).withOpacity(0.1),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
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
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        const Color(0xFF5B4FCF).withOpacity(0.08),
                                        const Color(0xFF7C6FE8).withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(24),
                                      topRight: Radius.circular(24),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF5B4FCF), Color(0xFF7C6FE8)],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.eco_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Plant Health Analysis',
                                              style: GoogleFonts.poppins(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF1A1A1A),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.check_circle,
                                                        size: 11,
                                                        color: Color(0xFF4CAF50),
                                                      ),
                                                      const SizedBox(width: 3),
                                                      Text(
                                                        'AI Powered',
                                                        style: GoogleFonts.inter(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w600,
                                                          color: const Color(0xFF4CAF50),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          // Share functionality
                                        },
                                        icon: const Icon(
                                          Icons.share_rounded,
                                          size: 20,
                                          color: Color(0xFF5B4FCF),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Markdown content directly
                                Container(
                                  constraints: const BoxConstraints(minHeight: 500),
                                  child: Markdown(
                                    data: _analysisResult!,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(20),
                                    styleSheet: MarkdownStyleSheet(
                                      h1: GoogleFonts.poppins(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF5B4FCF),
                                        height: 1.4,
                                      ),
                                      h2: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2C2C2C),
                                        height: 1.5,
                                      ),
                                      h3: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF424242),
                                        height: 1.5,
                                      ),
                                      p: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: const Color(0xFF5A5A5A),
                                        height: 1.7,
                                        letterSpacing: 0.2,
                                      ),
                                      strong: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2C2C2C),
                                      ),
                                      em: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        color: const Color(0xFF5B4FCF),
                                      ),
                                      listBullet: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: const Color(0xFF5B4FCF),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      listIndent: 20,
                                      blockquote: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: const Color(0xFF795548),
                                        fontStyle: FontStyle.italic,
                                      ),
                                      blockquotePadding: const EdgeInsets.only(left: 16),
                                      blockquoteDecoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(
                                            color: const Color(0xFF5B4FCF).withOpacity(0.3),
                                            width: 4,
                                          ),
                                        ),
                                      ),
                                      code: GoogleFonts.sourceCodePro(
                                        fontSize: 13,
                                        backgroundColor: const Color(0xFF5B4FCF).withOpacity(0.08),
                                        color: const Color(0xFF5B4FCF),
                                      ),
                                      codeblockPadding: const EdgeInsets.all(16),
                                      codeblockDecoration: BoxDecoration(
                                        color: const Color(0xFF5B4FCF).withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFF5B4FCF).withOpacity(0.2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }
}