class Plant {
  final String id;
  final String name;
  final String imagePath;
  final DateTime dateAdded;
  final String? notes;
  final List<String> careHistory;

  Plant({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.dateAdded,
    this.notes,
    List<String>? careHistory,
  }) : careHistory = careHistory ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'dateAdded': dateAdded.toIso8601String(),
      'notes': notes,
      'careHistory': careHistory,
    };
  }

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'],
      name: json['name'],
      imagePath: json['imagePath'],
      dateAdded: DateTime.parse(json['dateAdded']),
      notes: json['notes'],
      careHistory: List<String>.from(json['careHistory'] ?? []),
    );
  }

  Plant copyWith({
    String? id,
    String? name,
    String? imagePath,
    DateTime? dateAdded,
    String? notes,
    List<String>? careHistory,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      dateAdded: dateAdded ?? this.dateAdded,
      notes: notes ?? this.notes,
      careHistory: careHistory ?? this.careHistory,
    );
  }
}