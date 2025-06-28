import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../screens/plant_details_screen.dart';
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
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;

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
    if (images.isEmpty) return;
    
    List<File>? files;
    if (!kIsWeb) {
      files = images.map((xfile) => File(xfile.path)).toList();
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlantDetailsScreen(
          selectedImages: images,
          selectedFiles: files,
        ),
      ),
    ).then((result) {
      if (result != null && widget.onAnalysisComplete != null) {
        widget.onAnalysisComplete!(result);
      }
    });
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
      ],
    );
  }
}