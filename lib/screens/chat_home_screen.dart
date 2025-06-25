import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:uuid/uuid.dart';
import '../widgets/image_picker_widget.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final FocusNode _focusNode = FocusNode();
  
  bool _isLoading = false;
  late AnimationController _animationController;
  
  // Selected image for preview
  File? _selectedImageFile;
  Uint8List? _selectedWebImageBytes;
  String? _selectedImageName;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      id: const Uuid().v4(),
      content: 'Hello! 👋 I\'m your plant care assistant. How can I help you today?',
      isUser: false,
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  Future<void> _sendMessage({
    String? text,
    File? imageFile,
    Uint8List? webImageBytes,
    String? imageName,
  }) async {
    final messageText = text ?? _textController.text.trim();
    final hasImage = imageFile != null || webImageBytes != null || _selectedImageFile != null || _selectedWebImageBytes != null;
    
    if (messageText.isEmpty && !hasImage) return;

    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      content: messageText.isEmpty ? 'Image uploaded' : messageText,
      isUser: true,
      timestamp: DateTime.now(),
      imageFile: imageFile ?? _selectedImageFile,
      webImageBytes: webImageBytes ?? _selectedWebImageBytes,
      imageName: imageName ?? _selectedImageName,
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      // Clear selected image after sending
      _selectedImageFile = null;
      _selectedWebImageBytes = null;
      _selectedImageName = null;
    });

    _textController.clear();
    _scrollToBottom();

    try {
      final response = await ChatService.sendMessage(
        message: messageText,
        imageFile: imageFile ?? _selectedImageFile,
        webImageBytes: webImageBytes ?? _selectedWebImageBytes,
        imageName: imageName ?? _selectedImageName,
      );

      final botMessage = ChatMessage(
        id: const Uuid().v4(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(botMessage);
        _isLoading = false;
      });
    } catch (e) {
      final errorMessage = ChatMessage(
        id: const Uuid().v4(),
        content: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(errorMessage);
        _isLoading = false;
      });
    }

    _scrollToBottom();
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

  Future<void> _pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Don't send immediately, just store the image for the user to add text
        setState(() {
          if (kIsWeb) {
            _selectedWebImageBytes = null;
            _selectedImageName = image.name;
            // Load bytes for preview
            image.readAsBytes().then((bytes) {
              setState(() {
                _selectedWebImageBytes = bytes;
              });
            });
          } else {
            _selectedImageFile = File(image.path);
          }
        });
        
        // Focus on text input so user can add a message
        _focusNode.requestFocus();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to capture image: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Don't send immediately, just store the image for the user to add text
        setState(() {
          if (kIsWeb) {
            _selectedWebImageBytes = null;
            _selectedImageName = image.name;
            // Load bytes for preview
            image.readAsBytes().then((bytes) {
              setState(() {
                _selectedWebImageBytes = bytes;
              });
            });
          } else {
            _selectedImageFile = File(image.path);
          }
        });
        
        // Focus on text input so user can add a message
        _focusNode.requestFocus();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to select image: $e');
    }
  }

  void _showImageSourceDialog() {
    ImagePickerWidget.show(
      context,
      onImagesSelected: _onImageSelected,
      title: 'Add Image',
      allowMultiple: false, // Chat typically uses single images
    );
  }

  void _onImageSelected(List<XFile> images) {
    if (images.isNotEmpty) {
      final image = images.first;
      setState(() {
        if (kIsWeb) {
          _selectedWebImageBytes = null;
          _selectedImageName = image.name;
          // Load bytes for preview
          image.readAsBytes().then((bytes) {
            setState(() {
              _selectedWebImageBytes = bytes;
            });
          });
        } else {
          _selectedImageFile = File(image.path);
        }
      });
      
      // Focus on text input so user can add a message
      _focusNode.requestFocus();
    }
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5DC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: const Color(0xFF2D2D2D)),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2D2D2D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearSelectedImage() {
    setState(() {
      _selectedImageFile = null;
      _selectedWebImageBytes = null;
      _selectedImageName = null;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF7),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Color(0xFF2D2D2D),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plant Care Assistant',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
                Text(
                  'Online',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF8E8E8E),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFFFDF7),
        foregroundColor: const Color(0xFF2D2D2D),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE8E8E8),
          ),
        ),
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  return _buildLoadingMessage();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          
          // Loading indicator when typing
          if (_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(width: 48),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5DC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D2D2D)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Typing...',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF2D2D2D),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Input area
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFE8E8E8), width: 1),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Image preview if selected
                  if (_selectedImageFile != null || _selectedWebImageBytes != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Stack(
                        children: [
                          Container(
                            constraints: const BoxConstraints(
                              maxHeight: 120,
                              maxWidth: double.infinity,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE8E8E8)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _selectedWebImageBytes != null
                                  ? Image.memory(
                                      _selectedWebImageBytes!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : _selectedImageFile != null
                                      ? Image.file(
                                          _selectedImageFile!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        )
                                      : Container(),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: _clearSelectedImage,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
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
                    ),
                  ],
                  
                  // Input row
                  Row(
                    children: [
                      // Image picker button
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5DC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE8E8E8)),
                        ),
                        child: IconButton(
                          onPressed: _showImageSourceDialog,
                          icon: const Icon(
                            Icons.add_a_photo_rounded,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Text input
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFDF7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE8E8E8)),
                          ),
                          child: TextField(
                            controller: _textController,
                            focusNode: _focusNode,
                            decoration: InputDecoration(
                              hintText: 'Ask about your plants...',
                              hintStyle: GoogleFonts.inter(
                                color: const Color(0xFF8E8E8E),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            style: GoogleFonts.inter(
                              color: const Color(0xFF2D2D2D),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: (text) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Send button
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5DC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE8E8E8)),
                        ),
                        child: IconButton(
                          onPressed: () => _sendMessage(),
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFE8E8E8),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Color(0xFF2D2D2D),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5DC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D2D2D)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Thinking...',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF2D2D2D),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE8E8E8),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Color(0xFF2D2D2D),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
          ] else
            const SizedBox(width: 44),
          
          Expanded(
            child: Column(
              crossAxisAlignment: message.isUser 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: message.isUser 
                        ? const Color(0xFFF5F5DC)
                        : const Color(0xFFFFFDF7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image if present
                      if (message.hasImage) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            constraints: const BoxConstraints(
                              maxHeight: 200,
                              maxWidth: double.infinity,
                            ),
                            child: message.webImageBytes != null
                                ? Image.memory(
                                    message.webImageBytes!,
                                    fit: BoxFit.cover,
                                  )
                                : message.imageFile != null
                                    ? Image.file(
                                        message.imageFile!,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        height: 100,
                                        color: const Color(0xFFE8E8E8),
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Color(0xFF8E8E8E),
                                          ),
                                        ),
                                      ),
                          ),
                        ),
                        if (message.content.isNotEmpty) const SizedBox(height: 8),
                      ],
                      
                      // Message content
                      if (message.content.isNotEmpty)
                        message.isUser
                            ? Text(
                                message.content,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF2D2D2D),
                                  fontSize: 14,
                                ),
                              )
                            : MarkdownBody(
                                data: message.content,
                                styleSheet: MarkdownStyleSheet(
                                  p: GoogleFonts.inter(
                                    color: const Color(0xFF2D2D2D),
                                    fontSize: 14,
                                  ),
                                  h1: GoogleFonts.inter(
                                    color: const Color(0xFF2D2D2D),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  h2: GoogleFonts.inter(
                                    color: const Color(0xFF2D2D2D),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  h3: GoogleFonts.inter(
                                    color: const Color(0xFF2D2D2D),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  listBullet: GoogleFonts.inter(
                                    color: const Color(0xFF2D2D2D),
                                    fontSize: 14,
                                  ),
                                  strong: GoogleFonts.inter(
                                    color: const Color(0xFF2D2D2D),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: GoogleFonts.inter(
                    color: const Color(0xFF8E8E8E),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          if (message.isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE8E8E8),
              child: const Icon(
                Icons.person_rounded,
                color: Color(0xFF2D2D2D),
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}