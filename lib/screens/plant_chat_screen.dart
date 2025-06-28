import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/plant.dart';
import '../widgets/image_picker_widget.dart';

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? imagePaths;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.imagePaths,
  });
}

class PlantChatScreen extends StatefulWidget {
  final Plant plant;

  const PlantChatScreen({super.key, required this.plant});

  @override
  State<PlantChatScreen> createState() => _PlantChatScreenState();
}

class _PlantChatScreenState extends State<PlantChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isTyping = false;
  List<File> _selectedImages = [];
  List<XFile> _selectedXFiles = [];

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      message: 'Hello! I\'m your plant care assistant for ${widget.plant.name}. '
          'I can help you with watering schedules, disease identification, '
          'pruning tips, and general care advice. What would you like to know?',
      isUser: false,
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  void _showImageSourceDialog() {
    ImagePickerWidget.show(
      context,
      onImagesSelected: _onImagesSelected,
      title: 'Add Images to Chat',
      allowMultiple: true,
      primaryColor: const Color(0xFF5B4FCF),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: const Color(0xFF2E7D32)),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B4FCF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add_a_photo_rounded,
                        color: Color(0xFF5B4FCF),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Add More Photos?',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Would you like to take another photo or select from gallery?',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF757575),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Done',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF757575),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _pickFromCamera();
                        },
                        icon: const Icon(Icons.camera_alt_rounded, size: 18),
                        label: Text(
                          'Camera',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF5B4FCF),
                          side: BorderSide(
                            color: const Color(0xFF5B4FCF).withOpacity(0.3),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _pickFromGallery();
                        },
                        icon: const Icon(Icons.photo_library_rounded, size: 18),
                        label: Text(
                          'Gallery',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B4FCF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
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
                        color: const Color(0xFFE57373).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFE57373),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Error',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF757575),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Action
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B4FCF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'OK',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty && _selectedImages.isEmpty && _selectedXFiles.isEmpty) return;

    // Prepare image paths for the message
    List<String>? imagePaths;
    if (_selectedImages.isNotEmpty || _selectedXFiles.isNotEmpty) {
      imagePaths = kIsWeb 
          ? _selectedXFiles.map((xfile) => xfile.path).toList()
          : _selectedImages.map((file) => file.path).toList();
    }

    // Add user message
    final userMessage = ChatMessage(
      message: messageText.isNotEmpty ? messageText : 'Shared ${imagePaths?.length ?? 0} image(s)',
      isUser: true,
      timestamp: DateTime.now(),
      imagePaths: imagePaths,
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
      // Clear selected images after sending
      _selectedImages.clear();
      _selectedXFiles.clear();
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate bot response delay
    await Future.delayed(const Duration(milliseconds: 1000));

    // Generate bot response
    final botResponse = _generateBotResponse(messageText, hasImages: imagePaths != null && imagePaths.isNotEmpty);
    final botMessage = ChatMessage(
      message: botResponse,
      isUser: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(botMessage);
      _isTyping = false;
    });

    _scrollToBottom();
  }

  String _generateBotResponse(String userMessage, {bool hasImages = false}) {
    final message = userMessage.toLowerCase();
    final plantName = widget.plant.name.toLowerCase();

    // Handle image-based questions
    if (hasImages) {
      return 'Thank you for sharing the image(s)! I can see you\'ve uploaded photos. Based on what I can observe:\n\n'
          '• If you\'re showing me plant issues, look for signs like discolored leaves, spots, wilting, or pest damage\n'
          '• For plant identification, consider the leaf shape, growth pattern, and overall structure\n'
          '• For growth progress, compare with previous photos to track development\n\n'
          'For a detailed analysis of plant diseases or specific issues, I recommend using the "Scan Plant" feature in the main app, which provides comprehensive diagnosis and treatment recommendations.\n\n'
          'What specific question do you have about the image(s) you shared?';
    }

    // Watering related questions
    if (message.contains('water') || message.contains('watering')) {
      if (plantName.contains('tomato')) {
        return 'For tomatoes, water deeply 1-2 times per week. Check the soil - it should be moist but not waterlogged. Water at the base of the plant to avoid wetting the leaves, which can lead to disease.';
      } else if (plantName.contains('rose')) {
        return 'Roses need deep watering 2-3 times per week. Water at soil level to avoid wetting the leaves. Early morning is the best time to water roses.';
      } else if (plantName.contains('basil')) {
        return 'Keep basil soil consistently moist but not waterlogged. Water when the top inch of soil feels dry. Basil loves water but hates sitting in soggy soil.';
      } else {
        return 'For ${widget.plant.name}, water when the top inch of soil is dry. Most plants prefer deep, infrequent watering rather than frequent shallow watering.';
      }
    }

    // Sunlight related questions
    if (message.contains('sun') || message.contains('light')) {
      if (plantName.contains('tomato')) {
        return 'Tomatoes need 6-8 hours of direct sunlight daily. They\'re sun-loving plants that produce best fruit in full sun conditions.';
      } else if (plantName.contains('rose')) {
        return 'Roses need at least 6 hours of morning sunlight. Good air circulation is also important to prevent diseases.';
      } else if (plantName.contains('basil')) {
        return 'Basil requires 6-8 hours of direct sunlight. If grown indoors, place it in a south-facing window or under grow lights.';
      } else {
        return 'Most plants need bright, indirect light. Check the specific requirements for ${widget.plant.name}, but generally 4-6 hours of sunlight is good for most houseplants.';
      }
    }

    // Disease related questions
    if (message.contains('disease') || message.contains('sick') || message.contains('problem')) {
      return 'Common signs of plant diseases include yellowing leaves, brown spots, wilting, or unusual growth patterns. For ${widget.plant.name}, watch for:\n\n• Fungal issues (spots on leaves)\n• Pest problems (aphids, spider mites)\n• Nutrient deficiencies\n\nIf you notice any symptoms, you can use the main analyzer to get a detailed diagnosis!';
    }

    // Fertilizing questions
    if (message.contains('fertilize') || message.contains('feed') || message.contains('nutrients')) {
      return 'For ${widget.plant.name}, use a balanced fertilizer every 2-3 weeks during the growing season (spring and summer). Reduce or stop fertilizing in fall and winter when growth slows down. Always follow the package instructions and never over-fertilize.';
    }

    // Pruning questions
    if (message.contains('prune') || message.contains('trim') || message.contains('cut')) {
      if (plantName.contains('tomato')) {
        return 'Remove suckers (shoots between main stem and branches) regularly. Also remove lower leaves that touch the ground and any diseased or damaged parts.';
      } else if (plantName.contains('rose')) {
        return 'Prune roses in late winter/early spring. Remove dead, diseased, or weak canes. Cut at a 45-degree angle just above an outward-facing bud.';
      } else if (plantName.contains('basil')) {
        return 'Pinch off flower buds to encourage leaf growth. Harvest regularly by cutting stems just above a leaf node to promote bushy growth.';
      } else {
        return 'Regular pruning helps maintain plant shape and health. Remove dead, diseased, or damaged parts first. Then trim for shape and size as needed.';
      }
    }

    // Temperature questions
    if (message.contains('temperature') || message.contains('cold') || message.contains('hot')) {
      return 'Most plants prefer temperatures between 65-75°F (18-24°C). ${widget.plant.name} should be protected from extreme temperatures and drafts. Sudden temperature changes can stress plants.';
    }

    // General care questions
    if (message.contains('care') || message.contains('help') || message.contains('tips')) {
      return 'Here are some general care tips for ${widget.plant.name}:\n\n• Monitor soil moisture regularly\n• Provide adequate light\n• Watch for pests and diseases\n• Fertilize during growing season\n• Prune when necessary\n• Maintain proper humidity\n\nWhat specific aspect would you like to know more about?';
    }

    // Default response
    return 'That\'s a great question about ${widget.plant.name}! While I try to help with common plant care questions, for specific issues you might want to:\n\n• Check reputable gardening websites\n• Consult with local garden centers\n• Use the plant analysis feature in this app\n\nIs there anything else about watering, sunlight, or general care I can help with?';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Plant Assistant',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF1A1A1A),
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.plant.name,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B4FCF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF5B4FCF).withOpacity(0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: Color(0xFF5B4FCF),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return _buildTypingIndicator();
                    }
                    return _buildMessageBubble(_messages[index]);
                  },
                ),
              ),
              _buildMessageInput(),
            ],
          ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B4FCF), Color(0xFF7C6FE8)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5B4FCF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF5B4FCF).withOpacity(0.1)
                    : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: message.isUser
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: message.isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: message.isUser
                        ? const Color(0xFF5B4FCF).withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display images if present
                  if (message.imagePaths != null && message.imagePaths!.isNotEmpty) ...[
                    Container(
                      height: 120,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: message.imagePaths!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: kIsWeb
                                    ? Image.network(
                                        message.imagePaths![index],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: Colors.grey[300],
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      )
                                    : File(message.imagePaths![index]).existsSync()
                                        ? Image.file(
                                            File(message.imagePaths![index]),
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: Colors.grey[300],
                                            child: Icon(
                                              Icons.image_not_supported,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  // Display message text
                  if (message.message.isNotEmpty)
                    Text(
                      message.message,
                      style: GoogleFonts.inter(
                        color: message.isUser ? const Color(0xFF424242) : const Color(0xFF5A5A5A),
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF5B4FCF).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF5B4FCF).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Color(0xFF5B4FCF),
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5B4FCF), Color(0xFF7C6FE8)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B4FCF).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.3, end: 1.0),
      builder: (context, value, child) {
        return AnimatedBuilder(
          animation: AnimationController(
            duration: const Duration(milliseconds: 600),
            vsync: this,
          )..repeat(reverse: true),
          builder: (context, child) {
            return Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[400]?.withOpacity(value),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Selected Images Preview
            if (_selectedImages.isNotEmpty || _selectedXFiles.isNotEmpty) ...[
              Container(
                height: 80,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: (_selectedImages.isNotEmpty ? _selectedImages.length : _selectedXFiles.length),
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: kIsWeb
                                  ? Image.network(
                                      _selectedXFiles[index].path,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: Colors.grey[300],
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    )
                                  : Image.file(
                                      _selectedImages[index],
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 14,
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
            ],
            
            // Input Row
            Row(
              children: [
                // Image Button
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5B4FCF), Color(0xFF7C6FE8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5B4FCF).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _showImageSourceDialog,
                    icon: const Icon(
                      Icons.photo_camera_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Text Input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF5B4FCF).withOpacity(0.2)),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: widget.plant.name == 'General Plant Care' 
                            ? 'Ask about plants or share images...'
                            : 'Ask about ${widget.plant.name} or share images...',
                        hintStyle: GoogleFonts.inter(
                          color: const Color(0xFF9E9E9E),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: GoogleFonts.inter(
                        color: const Color(0xFF424242),
                        fontSize: 14,
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Send Button
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5B4FCF), Color(0xFF7C6FE8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5B4FCF).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}