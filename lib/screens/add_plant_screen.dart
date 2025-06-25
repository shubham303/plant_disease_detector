import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import '../models/plant.dart';
import '../services/plant_service.dart';
import '../widgets/image_picker_widget.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  String? _selectedPlantType;
  List<File> _selectedImages = [];
  List<XFile> _selectedXFiles = [];
  List<String> _supportedPlants = [];
  DateTime? _plantationDate;
  int? _ageInDays;
  bool _hasDirectSunlight = true;
  String _irrigationMethod = 'Manual watering';
  bool _isLoading = false;
  bool _isSaving = false;

  final List<String> _irrigationMethods = [
    'Manual watering',
    'Drip irrigation',
    'Sprinkler system',
    'Self-watering system',
    'Bottom watering',
    'Misting',
  ];

  @override
  void initState() {
    super.initState();
    _loadSupportedPlants();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSupportedPlants() async {
    setState(() => _isLoading = true);
    try {
      final plants = await PlantService.getSupportedPlants();
      setState(() {
        _supportedPlants = plants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedXFiles.add(image);
          if (!kIsWeb) {
            _selectedImages.add(File(image.path));
          }
        });
        
        // Ask user if they want to add more photos
        _showAddMoreDialog();
      }
    } catch (e) {
      _showErrorDialog('Failed to capture image: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          _selectedXFiles.addAll(images);
          if (!kIsWeb) {
            _selectedImages.addAll(images.map((xfile) => File(xfile.path)));
          }
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to select images: $e');
    }
  }

  void _showAddMoreDialog() {
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
              _pickFromCamera();
            },
            child: Text(
              'Camera',
              style: GoogleFonts.inter(color: const Color(0xFF2E7D32)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _pickFromGallery();
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

  void _calculateAge() {
    if (_plantationDate != null) {
      final now = DateTime.now();
      final difference = now.difference(_plantationDate!);
      setState(() {
        _ageInDays = difference.inDays;
      });
    }
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

  Widget _buildImageSourceOption({
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

  Future<String> _saveImageToLocalStorage(File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final plantsDir = Directory('${appDir.path}/plants');
      if (!await plantsDir.exists()) {
        await plantsDir.create(recursive: true);
      }
      
      final fileName = '${const Uuid().v4()}.jpg';
      final savedImage = File('${plantsDir.path}/$fileName');
      await imageFile.copy(savedImage.path);
      return savedImage.path;
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }

  Future<void> _savePlant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      List<String> imagePaths = [];
      
      if (!kIsWeb && _selectedImages.isNotEmpty) {
        for (File imageFile in _selectedImages) {
          String savedPath = await _saveImageToLocalStorage(imageFile);
          imagePaths.add(savedPath);
        }
      } else if (kIsWeb && _selectedXFiles.isNotEmpty) {
        imagePaths = _selectedXFiles.map((xfile) => xfile.path).toList();
      }

      final plant = Plant(
        id: const Uuid().v4(),
        name: _selectedPlantType!,
        plantType: _selectedPlantType!,
        imagePaths: imagePaths,
        dateAdded: DateTime.now(),
        plantationDate: _plantationDate,
        ageInDays: _ageInDays,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        hasDirectSunlight: _hasDirectSunlight,
        irrigationMethod: _irrigationMethod,
      );

      await PlantService.savePlant(plant);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${plant.name} added successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to save plant: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showErrorDialog(String message) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Add New Plant',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Selection Section
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Plant Photo',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  style: BorderStyle.solid,
                                  width: 2,
                                ),
                              ),
                              child: _selectedImages.isNotEmpty || _selectedXFiles.isNotEmpty
                                  ? _buildImageGrid()
                                  : _buildImagePlaceholder(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Plant Type Selection
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Plant Type',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[200]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedPlantType,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                              ),
                              hint: Text(
                                'Select plant type...',
                                style: GoogleFonts.inter(color: Colors.grey[600]),
                              ),
                              items: _supportedPlants.map((String plant) {
                                return DropdownMenuItem<String>(
                                  value: plant,
                                  child: Text(plant, style: GoogleFonts.inter()),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedPlantType = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a plant type';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),


                    const SizedBox(height: 20),

                    // Plantation Date and Age
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
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
                                Icons.schedule_rounded,
                                color: const Color(0xFF2E7D32),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Plantation Information',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Plantation Date
                          Text(
                            'When was it planted?',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _plantationDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  _plantationDate = picked;
                                });
                                _calculateAge();
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[50],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _plantationDate != null
                                        ? '${_plantationDate!.day}/${_plantationDate!.month}/${_plantationDate!.year}'
                                        : 'Select plantation date',
                                    style: GoogleFonts.inter(
                                      color: _plantationDate != null
                                          ? Colors.grey[800]
                                          : Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.grey[600],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          if (_ageInDays != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF2E7D32).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 18,
                                    color: const Color(0xFF2E7D32),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Plant age: $_ageInDays days old',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF2E7D32),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Growing Conditions
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
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
                                Icons.eco_rounded,
                                color: const Color(0xFF2E7D32),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Growing Conditions',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Direct Sunlight
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.wb_sunny,
                                  color: Colors.orange[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Gets direct sunlight',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: _hasDirectSunlight,
                                  onChanged: (value) {
                                    setState(() {
                                      _hasDirectSunlight = value;
                                    });
                                  },
                                  activeColor: Colors.orange[600],
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Irrigation Method
                          Text(
                            'How do you water this plant?',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[50],
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _irrigationMethod,
                                isExpanded: true,
                                icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                                items: _irrigationMethods.map((String method) {
                                  return DropdownMenuItem<String>(
                                    value: method,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.water_drop,
                                          size: 16,
                                          color: Colors.blue[600],
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          method,
                                          style: GoogleFonts.inter(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _irrigationMethod = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Notes Section
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Additional Notes',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'The more details you provide, the better care recommendations you\'ll receive. Include soil type, location, previous treatments, observed symptoms, etc.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'e.g., Planted in sandy soil, receives morning sunlight, recently showed yellow leaves, applied fertilizer last month...',
                              hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[200]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[200]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF2E7D32)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            style: GoogleFonts.inter(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    ElevatedButton(
                      onPressed: _isSaving ? null : _savePlant,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Add Plant',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_a_photo_rounded,
            size: 40,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tap to add photos',
          style: GoogleFonts.inter(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Camera, Gallery, or Multiple',
          style: GoogleFonts.inter(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildImageGrid() {
    return Container(
      constraints: const BoxConstraints(minHeight: 200),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: (_selectedImages.isNotEmpty ? _selectedImages.length : _selectedXFiles.length) + 1,
        itemBuilder: (context, index) {
          if (index == (_selectedImages.isNotEmpty ? _selectedImages.length : _selectedXFiles.length)) {
            // Add more button
            return GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add More',
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: kIsWeb
                      ? Image.network(
                          _selectedXFiles[index].path,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
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
                      color: Colors.red.withOpacity(0.8),
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
          );
        },
      ),
    );
  }
}