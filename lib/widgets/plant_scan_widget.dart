import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:velocity_x/velocity_x.dart';
import '../services/plant_analysis_service.dart';
import 'image_picker_widget.dart';

class PlantScanWidget extends StatefulWidget {
  final String? plantType;
  final Function(String result)? onAnalysisComplete;
  final String title;

  const PlantScanWidget({
    super.key,
    this.plantType,
    this.onAnalysisComplete,
    this.title = 'Plant Analysis',
  });

  @override
  State<PlantScanWidget> createState() => _PlantScanWidgetState();
}

class _PlantScanWidgetState extends State<PlantScanWidget> with SingleTickerProviderStateMixin {
  final TextEditingController _descriptionController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;
  
  List<File> _selectedImages = [];
  List<XFile> _selectedXFiles = [];
  String? _analysisResult;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showImageSourceDialog() {
    ImagePickerWidget.show(
      context,
      onImagesSelected: _onImagesSelected,
      title: 'Add Plant Images',
      allowMultiple: true,
    );
  }

  void _onImagesSelected(List<XFile> images) {
    setState(() {
      _selectedXFiles.addAll(images);
      if (!kIsWeb) {
        _selectedImages.addAll(images.map((xfile) => File(xfile.path)));
      }
    });
  }

  void _removeImage(int index) {
    setState(() {
      if (index < _selectedXFiles.length) {
        _selectedXFiles.removeAt(index);
      }
      if (!kIsWeb && index < _selectedImages.length) {
        _selectedImages.removeAt(index);
      }
    });
  }

  Future<void> _analyzeImages() async {
    if (_selectedImages.isEmpty && _selectedXFiles.isEmpty) {
      _showErrorDialog('Please select at least one image');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final File? imageFile = !kIsWeb && _selectedImages.isNotEmpty 
          ? _selectedImages.first 
          : null;
      
      final String description = _descriptionController.text.trim();
      final String fullContext = widget.plantType != null 
          ? 'Plant type: ${widget.plantType}. Additional description: $description'
          : description;

      final result = await PlantAnalysisService.analyzeImage(
        imageFile,
        plantName: widget.plantType ?? 'Unknown',
        context: fullContext,
      );
      
      setState(() {
        _analysisResult = result;
      });

      if (widget.onAnalysisComplete != null) {
        widget.onAnalysisComplete!(result);
      }
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
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: context.textTheme.bodyMedium?.copyWith(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.title.isNotEmpty) ...[
          Text(
            widget.title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF424242),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Scan Button
        ScaleTransition(
          scale: _bounceAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5B4FCF), Color(0xFF7C6FE8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B4FCF).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showImageSourceDialog,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Scan Plant',
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
        ),

        if (_selectedImages.isNotEmpty || _selectedXFiles.isNotEmpty) ...[
          const SizedBox(height: 20),
          
          // Image Preview
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: (_selectedImages.isNotEmpty ? _selectedImages.length : _selectedXFiles.length) + 1,
              itemBuilder: (context, index) {
                if (index == (_selectedImages.isNotEmpty ? _selectedImages.length : _selectedXFiles.length)) {
                  // Add more button
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: _showImageSourceDialog,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF43A047).withOpacity(0.1),
                              const Color(0xFF66BB6A).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF43A047).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              color: const Color(0xFF43A047),
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add More',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF43A047),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: kIsWeb
                              ? Image.network(
                                  _selectedXFiles[index].path,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: const Color(0xFFEEEEEE),
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Color(0xFFBDBDBD),
                                    ),
                                  ),
                                )
                              : Image.file(
                                  _selectedImages[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Description Input
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Additional Details (Optional)',
              hintText: 'Describe symptoms or concerns...',
              hintStyle: GoogleFonts.inter(
                color: const Color(0xFF9E9E9E),
                fontSize: 14,
              ),
            ),
            style: GoogleFonts.inter(fontSize: 14),
          ),

          const SizedBox(height: 20),

          // Analyze Button
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 54,
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
                  blurRadius: 12,
                  offset: const Offset(0, 6),
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
                              size: 20,
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

        // Analysis Result
        if (_analysisResult != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFE8F5E9),
                  const Color(0xFFF1F8E9),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF66BB6A).withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
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
                        color: const Color(0xFF43A047).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.analytics_rounded,
                        color: Color(0xFF43A047),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Analysis Complete',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2E7D32),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _analysisResult!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF424242),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}