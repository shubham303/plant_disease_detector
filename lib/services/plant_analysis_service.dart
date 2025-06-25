import 'dart:io';
import 'package:flutter/services.dart';

class PlantAnalysisService {
  static Future<String> analyzeImage(File? imageFile, {String? plantName, String? context}) async {
    try {
      // Simulate processing time
      await Future.delayed(const Duration(seconds: 2));
      
      // Read the dummy markdown file from assets
      String analysis = await rootBundle.loadString('assets/sample_analysis.md');
      
      // If plant name is provided, customize the analysis
      if (plantName != null && plantName.isNotEmpty) {
        analysis = analysis.replaceAll('Sample Plant', plantName);
        analysis = analysis.replaceAll('tomato', plantName.toLowerCase());
        analysis = analysis.replaceAll('Tomato', plantName);
      }

      // If additional context is provided, add it to the analysis
      if (context != null && context.isNotEmpty) {
        analysis = 'Additional Context: $context\n\n$analysis';
      }
      
      return analysis;
    } catch (e) {
      throw Exception('Failed to analyze image: $e');
    }
  }
}