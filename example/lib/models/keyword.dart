class Keyword {
  final String id;
  final String keyword;
  final int currentPosition;
  final int previousPosition;
  final DateTime lastUpdated;
  final int searchVolume;
  final String difficulty;

  Keyword({
    required this.id,
    required this.keyword,
    required this.currentPosition,
    required this.previousPosition,
    required this.lastUpdated,
    this.searchVolume = 0,
    this.difficulty = 'Medium',
  });

  // Calculer la différence de position
  int get positionDifference => previousPosition - currentPosition;

  // Obtenir le trend (up, down, stable)
  String get trend {
    if (positionDifference > 0) return 'up';
    if (positionDifference < 0) return 'down';
    return 'stable';
  }

  // Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'keyword': keyword,
      'currentPosition': currentPosition,
      'previousPosition': previousPosition,
      'lastUpdated': lastUpdated.toIso8601String(),
      'searchVolume': searchVolume,
      'difficulty': difficulty,
    };
  }

  // Création depuis JSON
  factory Keyword.fromJson(Map<String, dynamic> json) {
    return Keyword(
      id: json['id'] as String,
      keyword: json['keyword'] as String,
      currentPosition: json['currentPosition'] as int,
      previousPosition: json['previousPosition'] as int,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      searchVolume: json['searchVolume'] as int? ?? 0,
      difficulty: json['difficulty'] as String? ?? 'Medium',
    );
  }

  // Copier avec modifications
  Keyword copyWith({
    String? id,
    String? keyword,
    int? currentPosition,
    int? previousPosition,
    DateTime? lastUpdated,
    int? searchVolume,
    String? difficulty,
  }) {
    return Keyword(
      id: id ?? this.id,
      keyword: keyword ?? this.keyword,
      currentPosition: currentPosition ?? this.currentPosition,
      previousPosition: previousPosition ?? this.previousPosition,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      searchVolume: searchVolume ?? this.searchVolume,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
