import 'dart:io';
import 'dart:typed_data';

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final File? imageFile;
  final Uint8List? webImageBytes;
  final String? imageName;
  final bool isLoading;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.imageFile,
    this.webImageBytes,
    this.imageName,
    this.isLoading = false,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    File? imageFile,
    Uint8List? webImageBytes,
    String? imageName,
    bool? isLoading,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      imageFile: imageFile ?? this.imageFile,
      webImageBytes: webImageBytes ?? this.webImageBytes,
      imageName: imageName ?? this.imageName,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get hasImage => imageFile != null || webImageBytes != null;
}