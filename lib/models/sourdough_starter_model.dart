import 'dart:convert';

class SourdoughStarter {
  String name;
  String type;
  DateTime lastFed;
  List<String> history;
  bool fridgeMode;
  double temperature;
  List<String> feedingPhotos; // [just fed, peak]

  SourdoughStarter({
    required this.name,
    required this.type,
    required this.lastFed,
    this.history = const [],
    this.fridgeMode = false,
    this.temperature = 20.0,
    this.feedingPhotos = const [],
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'lastFed': lastFed.toIso8601String(),
    'history': history,
    'fridgeMode': fridgeMode,
    'temperature': temperature,
    'feedingPhotos': feedingPhotos,
  };

  factory SourdoughStarter.fromJson(Map<String, dynamic> json) => SourdoughStarter(
    name: json['name'],
    type: json['type'],
    lastFed: DateTime.parse(json['lastFed']),
    history: List<String>.from(json['history'] ?? []),
    fridgeMode: json['fridgeMode'] ?? false,
    temperature: (json['temperature'] ?? 20.0).toDouble(),
    feedingPhotos: List<String>.from(json['feedingPhotos'] ?? []),
  );
}
