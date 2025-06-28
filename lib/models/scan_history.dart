class ScanHistory {
  final String id;
  final String plantId;
  final DateTime scanDate;
  final String diseaseName;
  final double confidence;
  final String imageUrl;
  final String description;
  final List<String> symptoms;
  final List<String> treatments;
  final String severity;

  ScanHistory({
    required this.id,
    required this.plantId,
    required this.scanDate,
    required this.diseaseName,
    required this.confidence,
    required this.imageUrl,
    required this.description,
    required this.symptoms,
    required this.treatments,
    required this.severity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantId': plantId,
      'scanDate': scanDate.toIso8601String(),
      'diseaseName': diseaseName,
      'confidence': confidence,
      'imageUrl': imageUrl,
      'description': description,
      'symptoms': symptoms,
      'treatments': treatments,
      'severity': severity,
    };
  }

  factory ScanHistory.fromJson(Map<String, dynamic> json) {
    return ScanHistory(
      id: json['id'] ?? '',
      plantId: json['plantId'] ?? '',
      scanDate: DateTime.parse(json['scanDate'] ?? DateTime.now().toIso8601String()),
      diseaseName: json['diseaseName'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      symptoms: List<String>.from(json['symptoms'] ?? []),
      treatments: List<String>.from(json['treatments'] ?? []),
      severity: json['severity'] ?? 'Unknown',
    );
  }

  ScanHistory copyWith({
    String? id,
    String? plantId,
    DateTime? scanDate,
    String? diseaseName,
    double? confidence,
    String? imageUrl,
    String? description,
    List<String>? symptoms,
    List<String>? treatments,
    String? severity,
  }) {
    return ScanHistory(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      scanDate: scanDate ?? this.scanDate,
      diseaseName: diseaseName ?? this.diseaseName,
      confidence: confidence ?? this.confidence,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      symptoms: symptoms ?? this.symptoms,
      treatments: treatments ?? this.treatments,
      severity: severity ?? this.severity,
    );
  }
}