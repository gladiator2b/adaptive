class KeywordTracking {
  final String keywordId;
  final int position;
  final DateTime date;
  final int searchVolume;

  KeywordTracking({
    required this.keywordId,
    required this.position,
    required this.date,
    this.searchVolume = 0,
  });

  // Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'keywordId': keywordId,
      'position': position,
      'date': date.toIso8601String(),
      'searchVolume': searchVolume,
    };
  }

  // Création depuis JSON
  factory KeywordTracking.fromJson(Map<String, dynamic> json) {
    return KeywordTracking(
      keywordId: json['keywordId'] as String,
      position: json['position'] as int,
      date: DateTime.parse(json['date'] as String),
      searchVolume: json['searchVolume'] as int? ?? 0,
    );
  }
}
