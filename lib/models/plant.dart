class Plant {
  final String id;
  final String name;
  final String plantType;
  final List<String> imagePaths;
  final DateTime dateAdded;
  final DateTime? plantationDate;
  final int? ageInDays;
  final String? notes;
  final bool hasDirectSunlight;
  final String irrigationMethod;
  final List<String> careHistory;

  Plant({
    required this.id,
    required this.name,
    required this.plantType,
    required this.imagePaths,
    required this.dateAdded,
    this.plantationDate,
    this.ageInDays,
    this.notes,
    this.hasDirectSunlight = true,
    this.irrigationMethod = 'Manual watering',
    List<String>? careHistory,
  }) : careHistory = careHistory ?? [];

  // Backward compatibility getter
  String get imagePath => imagePaths.isNotEmpty ? imagePaths.first : '';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plantType': plantType,
      'imagePaths': imagePaths,
      'dateAdded': dateAdded.toIso8601String(),
      'plantationDate': plantationDate?.toIso8601String(),
      'ageInDays': ageInDays,
      'notes': notes,
      'hasDirectSunlight': hasDirectSunlight,
      'irrigationMethod': irrigationMethod,
      'careHistory': careHistory,
      // Backward compatibility
      'imagePath': imagePath,
    };
  }

  factory Plant.fromJson(Map<String, dynamic> json) {
    // Handle backward compatibility for imagePath vs imagePaths
    List<String> images = [];
    if (json['imagePaths'] != null) {
      images = List<String>.from(json['imagePaths']);
    } else if (json['imagePath'] != null && json['imagePath'].isNotEmpty) {
      images = [json['imagePath']];
    }

    return Plant(
      id: json['id'],
      name: json['name'],
      plantType: json['plantType'] ?? json['name'], // Fallback for backward compatibility
      imagePaths: images,
      dateAdded: DateTime.parse(json['dateAdded']),
      plantationDate: json['plantationDate'] != null 
          ? DateTime.parse(json['plantationDate']) 
          : null,
      ageInDays: json['ageInDays'],
      notes: json['notes'],
      hasDirectSunlight: json['hasDirectSunlight'] ?? true,
      irrigationMethod: json['irrigationMethod'] ?? 'Manual watering',
      careHistory: List<String>.from(json['careHistory'] ?? []),
    );
  }

  Plant copyWith({
    String? id,
    String? name,
    String? plantType,
    List<String>? imagePaths,
    DateTime? dateAdded,
    DateTime? plantationDate,
    int? ageInDays,
    String? notes,
    bool? hasDirectSunlight,
    String? irrigationMethod,
    List<String>? careHistory,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      plantType: plantType ?? this.plantType,
      imagePaths: imagePaths ?? this.imagePaths,
      dateAdded: dateAdded ?? this.dateAdded,
      plantationDate: plantationDate ?? this.plantationDate,
      ageInDays: ageInDays ?? this.ageInDays,
      notes: notes ?? this.notes,
      hasDirectSunlight: hasDirectSunlight ?? this.hasDirectSunlight,
      irrigationMethod: irrigationMethod ?? this.irrigationMethod,
      careHistory: careHistory ?? this.careHistory,
    );
  }
}