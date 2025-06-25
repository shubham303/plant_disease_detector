import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ChatService {
  static const String _baseUrl = 'https://api.example.com'; // Replace with your actual API endpoint
  
  static Future<String> sendMessage({
    required String message,
    File? imageFile,
    Uint8List? webImageBytes,
    String? imageName,
  }) async {
    try {
      // For now, simulate server response with plant care advice
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      if (imageFile != null || webImageBytes != null) {
        return _generateImageResponse(message);
      } else {
        return _generateTextResponse(message);
      }
    } catch (e) {
      throw Exception('Failed to get response from server: $e');
    }
  }
  
  static String _generateImageResponse(String message) {
    return """# Plant Analysis Results

## Overview
Based on the image you've shared, I can help you with plant care advice.

## General Recommendations
- **Watering**: Check soil moisture before watering
- **Light**: Ensure adequate sunlight (6-8 hours daily)
- **Soil**: Well-draining soil is essential

## Possible Issues to Watch For
- Yellowing leaves (overwatering or nutrient deficiency)
- Brown spots (fungal infections)
- Wilting (underwatering or root problems)

## Next Steps
1. Monitor your plant daily
2. Adjust watering schedule if needed
3. Consider fertilizing every 2-4 weeks

*Note: For accurate disease diagnosis, please consult with a plant pathologist.*""";
  }
  
  static String _generateTextResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('water') || lowerMessage.contains('watering')) {
      return """# Watering Guidelines 💧

## How Often to Water
- **Most plants**: When top inch of soil is dry
- **Succulents**: Every 1-2 weeks
- **Tropical plants**: Keep soil consistently moist

## Signs of Overwatering
- Yellowing leaves
- Musty smell
- Soft, brown roots

## Signs of Underwatering
- Wilting despite moist soil
- Dry, crispy leaves
- Stunted growth""";
    }
    
    if (lowerMessage.contains('disease') || lowerMessage.contains('sick') || lowerMessage.contains('problem')) {
      return """# Common Plant Problems 🌿

## Fungal Issues
- **Symptoms**: Dark spots, fuzzy growth
- **Treatment**: Improve air circulation, reduce humidity
- **Prevention**: Avoid overhead watering

## Pest Problems
- **Aphids**: Small green/black bugs
- **Spider mites**: Tiny webs on leaves
- **Treatment**: Insecticidal soap or neem oil

## Nutrient Deficiencies
- **Nitrogen**: Yellow lower leaves
- **Phosphorus**: Purple/red tinting
- **Potassium**: Brown leaf edges""";
    }
    
    if (lowerMessage.contains('light') || lowerMessage.contains('sun')) {
      return """# Light Requirements ☀️

## Light Categories
- **Full sun**: 6+ hours direct sunlight
- **Partial sun**: 4-6 hours direct sunlight
- **Partial shade**: 2-4 hours direct sunlight
- **Full shade**: Less than 2 hours direct sunlight

## Signs of Too Much Light
- Scorched, brown leaves
- Wilting during hot afternoons
- Bleached appearance

## Signs of Too Little Light
- Leggy, stretched growth
- Small, pale leaves
- Poor flowering""";
    }
    
    return """# Hello! 👋

I'm your plant care assistant. I can help you with:

## What I Can Do
- 🌱 **Plant identification** and care advice
- 💧 **Watering schedules** and techniques
- 🐛 **Pest and disease** diagnosis
- ☀️ **Light requirements** for different plants
- 🌿 **General plant care** tips

## How to Get Help
- Ask me questions about your plants
- Upload photos for visual analysis
- Describe any problems you're seeing

**Example questions:**
- "How often should I water my tomatoes?"
- "What's wrong with my plant's leaves?"
- "My plant is wilting, what should I do?"

Feel free to ask me anything about plant care!""";
  }
}