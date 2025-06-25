import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatelessWidget {
  final Function(List<XFile> images) onImagesSelected;
  final String title;
  final bool allowMultiple;

  const ImagePickerWidget({
    super.key,
    required this.onImagesSelected,
    this.title = 'Add Images',
    this.allowMultiple = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildImageSourceOption(
                  context: context,
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromCamera(context);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildImageSourceOption(
                  context: context,
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromGallery(context);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildImageSourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: const Color(0xFF2E7D32)),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        onImagesSelected([image]);
        
        if (allowMultiple && context.mounted) {
          // Ask user if they want to add more photos
          _showAddMoreDialog(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'Failed to capture image: $e');
      }
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      
      if (allowMultiple) {
        final List<XFile> images = await picker.pickMultiImage(
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
        
        if (images.isNotEmpty) {
          onImagesSelected(images);
        }
      } else {
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
        
        if (image != null) {
          onImagesSelected([image]);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'Failed to select images: $e');
      }
    }
  }

  void _showAddMoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Add More Photos?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Would you like to take another photo or select from gallery?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Done',
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _pickFromCamera(context);
            },
            child: Text(
              'Camera',
              style: GoogleFonts.inter(color: const Color(0xFF2E7D32)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _pickFromGallery(context);
            },
            child: Text(
              'Gallery',
              style: GoogleFonts.inter(color: const Color(0xFF2E7D32)),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Error', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text(message, style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Static method to show the image picker bottom sheet
  static void show(
    BuildContext context, {
    required Function(List<XFile> images) onImagesSelected,
    String title = 'Add Images',
    bool allowMultiple = true,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ImagePickerWidget(
        onImagesSelected: onImagesSelected,
        title: title,
        allowMultiple: allowMultiple,
      ),
    );
  }
}