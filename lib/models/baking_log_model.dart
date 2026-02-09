import 'package:flutter/foundation.dart';

class BakingPhoto {
  final String imagePath;
  final DateTime timestamp;
  final String stepName; // z.B. "Nach Kneten", "Nach 4h Gärung", etc.

  BakingPhoto({
    required this.imagePath,
    required this.timestamp,
    required this.stepName,
  });

  Map<String, dynamic> toJson() => {
    'imagePath': imagePath,
    'timestamp': timestamp.toIso8601String(),
    'stepName': stepName,
  };

  factory BakingPhoto.fromJson(Map<String, dynamic> json) => BakingPhoto(
    imagePath: json['imagePath'],
    timestamp: DateTime.parse(json['timestamp']),
    stepName: json['stepName'],
  );
}

class BakingLogEntry {
  final String id;
  final String recipeName;
  final DateTime bakeDate;
  final List<BakingPhoto> photos;
  final String notes;
  final int rating; // 1-5 Sterne
  final String result; // z.B. "Perfekt", "Zu trocken", "Zu dunkel"
  
  // Bedingungen tracken
  final double roomTemperature; // °C
  final double doughTemperature; // °C
  final int totalBakeTime; // Minuten
  final double hydrationPercentage; // %

  BakingLogEntry({
    required this.id,
    required this.recipeName,
    required this.bakeDate,
    required this.photos,
    required this.notes,
    required this.rating,
    required this.result,
    required this.roomTemperature,
    required this.doughTemperature,
    required this.totalBakeTime,
    required this.hydrationPercentage,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'recipeName': recipeName,
    'bakeDate': bakeDate.toIso8601String(),
    'photos': photos.map((p) => p.toJson()).toList(),
    'notes': notes,
    'rating': rating,
    'result': result,
    'roomTemperature': roomTemperature,
    'doughTemperature': doughTemperature,
    'totalBakeTime': totalBakeTime,
    'hydrationPercentage': hydrationPercentage,
  };

  factory BakingLogEntry.fromJson(Map<String, dynamic> json) => BakingLogEntry(
    id: json['id'],
    recipeName: json['recipeName'],
    bakeDate: DateTime.parse(json['bakeDate']),
    photos: (json['photos'] as List).map((p) => BakingPhoto.fromJson(p)).toList(),
    notes: json['notes'],
    rating: json['rating'],
    result: json['result'],
    roomTemperature: json['roomTemperature'],
    doughTemperature: json['doughTemperature'],
    totalBakeTime: json['totalBakeTime'],
    hydrationPercentage: json['hydrationPercentage'],
  );
}

class BakingLogService extends ChangeNotifier {
  final List<BakingLogEntry> _logs = [];

  List<BakingLogEntry> get logs => _logs;

  void addLog(BakingLogEntry entry) {
    _logs.add(entry);
    notifyListeners();
  }

  void updateLog(String id, BakingLogEntry updatedEntry) {
    final index = _logs.indexWhere((log) => log.id == id);
    if (index != -1) {
      _logs[index] = updatedEntry;
      notifyListeners();
    }
  }

  BakingLogEntry? getLogById(String id) {
    try {
      return _logs.firstWhere((log) => log.id == id);
    } catch (e) {
      return null;
    }
  }

  List<BakingLogEntry> getLogsByRecipe(String recipeName) {
    return _logs.where((log) => log.recipeName == recipeName).toList();
  }
}
