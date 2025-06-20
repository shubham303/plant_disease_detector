import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/plant.dart';

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
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
  bool _isTyping = false;

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

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      message: messageText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate bot response delay
    await Future.delayed(const Duration(milliseconds: 1000));

    // Generate bot response
    final botResponse = _generateBotResponse(messageText);
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

  String _generateBotResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    final plantName = widget.plant.name.toLowerCase();

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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plant Assistant',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Text(
              widget.plant.name,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Column(
        children: [
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Color(0xFF2E7D32),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF2E7D32)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: message.isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: message.isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.message,
                style: GoogleFonts.inter(
                  color: message.isUser ? Colors.white : Colors.grey[800],
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Color(0xFF2E7D32),
                size: 20,
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Color(0xFF2E7D32),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Ask about ${widget.plant.name}...',
                    hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  style: GoogleFonts.inter(),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}