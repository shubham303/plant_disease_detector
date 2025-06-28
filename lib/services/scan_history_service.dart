import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_history.dart';

class ScanHistoryService {
  static const String _scanHistoryKey = 'scan_history';

  static Future<List<ScanHistory>> getAllScanHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? scanHistoryJson = prefs.getString(_scanHistoryKey);
    
    if (scanHistoryJson == null) return [];
    
    final List<dynamic> scanHistoryList = json.decode(scanHistoryJson);
    return scanHistoryList.map((json) => ScanHistory.fromJson(json)).toList();
  }

  static Future<List<ScanHistory>> getScanHistoryForPlant(String plantId) async {
    final allHistory = await getAllScanHistory();
    return allHistory.where((scan) => scan.plantId == plantId).toList()
      ..sort((a, b) => b.scanDate.compareTo(a.scanDate));
  }

  static Future<void> addScanHistory(ScanHistory scanHistory) async {
    final prefs = await SharedPreferences.getInstance();
    final allHistory = await getAllScanHistory();
    
    allHistory.add(scanHistory);
    
    final String updatedJson = json.encode(
      allHistory.map((scan) => scan.toJson()).toList(),
    );
    
    await prefs.setString(_scanHistoryKey, updatedJson);
  }

  static Future<void> deleteScanHistory(String scanId) async {
    final prefs = await SharedPreferences.getInstance();
    final allHistory = await getAllScanHistory();
    
    allHistory.removeWhere((scan) => scan.id == scanId);
    
    final String updatedJson = json.encode(
      allHistory.map((scan) => scan.toJson()).toList(),
    );
    
    await prefs.setString(_scanHistoryKey, updatedJson);
  }

  // Generate dummy scan history for testing
  static Future<void> generateDummyScanHistory(String plantId) async {
    final dummyDiseases = [
      {
        'name': 'Leaf Spot',
        'confidence': 0.89,
        'description': 'Fungal disease causing circular spots on leaves',
        'symptoms': ['Brown circular spots', 'Yellow halos around spots', 'Premature leaf drop'],
        'treatments': ['Remove affected leaves', 'Apply fungicide', 'Improve air circulation'],
        'severity': 'Moderate',
      },
      {
        'name': 'Powdery Mildew',
        'confidence': 0.92,
        'description': 'White powdery coating on leaf surfaces',
        'symptoms': ['White powdery substance', 'Leaf curling', 'Stunted growth'],
        'treatments': ['Spray with baking soda solution', 'Remove infected parts', 'Increase sunlight exposure'],
        'severity': 'Mild',
      },
      {
        'name': 'Root Rot',
        'confidence': 0.78,
        'description': 'Fungal infection affecting root system',
        'symptoms': ['Yellowing leaves', 'Wilting despite moist soil', 'Black or brown roots'],
        'treatments': ['Reduce watering', 'Improve drainage', 'Repot with fresh soil'],
        'severity': 'Severe',
      },
      {
        'name': 'Healthy',
        'confidence': 0.95,
        'description': 'No disease detected - plant appears healthy',
        'symptoms': ['Vibrant green leaves', 'Strong stem', 'Normal growth pattern'],
        'treatments': ['Continue regular care', 'Monitor for changes', 'Maintain current watering schedule'],
        'severity': 'None',
      },
    ];

    final random = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < 3; i++) {
      final disease = dummyDiseases[i % dummyDiseases.length];
      final scanHistory = ScanHistory(
        id: 'scan_${plantId}_${random}_$i',
        plantId: plantId,
        scanDate: DateTime.now().subtract(Duration(days: i * 7)),
        diseaseName: disease['name'] as String,
        confidence: disease['confidence'] as double,
        imageUrl: 'assets/images/plant${i % 3 + 1}.jpg',
        description: disease['description'] as String,
        symptoms: disease['symptoms'] as List<String>,
        treatments: disease['treatments'] as List<String>,
        severity: disease['severity'] as String,
      );
      
      await addScanHistory(scanHistory);
    }
  }
}