import 'dart:io';
import 'package:flutter/services.dart';

class PlantAnalysisService {
  static Future<String> analyzeImage(File? imageFile) async {
    try {
      // Simulate processing time
      await Future.delayed(const Duration(seconds: 2));
      
      // Read the dummy markdown file from assets
      String analysis = await rootBundle.loadString('assets/sample_analysis.md');
      
      return analysis;
    } catch (e) {
      throw Exception('Failed to analyze image: $e');
    }
  }
}