import 'dart:convert';

class SourdoughStarter {
  String name;
  String type;
  DateTime lastFed;
  bool isRefrigerated;
  List<String> notes;

  SourdoughStarter({
    required this.name,
    required this.type,
    required this.lastFed,
    this.isRefrigerated = false,
    required this.notes,
  });

  // Verwandelt das Objekt in Text für den Speicher
  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'lastFed': lastFed.toIso8601String(),
        'isRefrigerated': isRefrigerated,
        'notes': notes,
      };

  // Erstellt aus Speicher-Text wieder ein Objekt
  factory SourdoughStarter.fromJson(Map<String, dynamic> json) => SourdoughStarter(
      name: json['name'] ?? 'Unbekannt',
      type: json['type'] ?? 'Weizen',
      lastFed: json['lastFed'] != null 
          ? DateTime.parse(json['lastFed']) 
          : DateTime.now(),
      isRefrigerated: json['isRefrigerated'] ?? false,
      notes: json['notes'] != null ? List<String>.from(json['notes']) : [],
    );
}