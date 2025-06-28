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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF424242),
              size: 20,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Plant Analysis Details',
          style: GoogleFonts.poppins(
            color: const Color(0xFF424242),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: PageView.builder(
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
                ),
              ),
              if (widget.selectedImages.length > 1) ...[
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Swipe to view all ${widget.selectedImages.length} images',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF757575),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Plant Selection Dropdown
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
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
                            color: const Color(0xFF43A047).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.local_florist_rounded,
                            color: Color(0xFF43A047),
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
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF43A047)),
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
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Additional Details
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
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
                            color: const Color(0xFF5B4FCF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
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
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Analyze Button
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isLoading
                        ? [const Color(0xFF81C784), const Color(0xFFA5D6A7)]
                        : [const Color(0xFF66BB6A), const Color(0xFF81C784)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF66BB6A).withOpacity(0.3),
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
                                  Icons.auto_awesome_rounded,
                                  color: Colors.white,
                                  size: 22,
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

              // Analysis Result
              if (_analysisResult != null) ...[
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.analytics_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Analysis Results',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: MarkdownBody(
                          data: _analysisResult!,
                          styleSheet: MarkdownStyleSheet(
                            h1: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2E7D32),
                            ),
                            h2: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF388E3C),
                            ),
                            h3: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF424242),
                            ),
                            p: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF616161),
                              height: 1.6,
                            ),
                            strong: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF424242),
                            ),
                            em: GoogleFonts.inter(
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFF616161),
                            ),
                            listBullet: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF43A047),
                            ),
                            blockquote: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF757575),
                              fontStyle: FontStyle.italic,
                            ),
                            blockquoteDecoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: const Color(0xFF43A047),
                                  width: 4,
                                ),
                              ),
                            ),
                            code: GoogleFonts.robotoMono(
                              fontSize: 13,
                              backgroundColor: const Color(0xFFF5F7FA),
                              color: const Color(0xFF5B4FCF),
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(8),
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
    );
  }
}