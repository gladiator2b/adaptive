import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/keyword.dart';
import '../models/keyword_tracking.dart';

class StorageService {
  static const String _keywordsKey = 'keywords';
  static const String _trackingKey = 'keyword_tracking';

  // Sauvegarder les mots clés
  Future<void> saveKeywords(List<Keyword> keywords) async {
    final prefs = await SharedPreferences.getInstance();
    final keywordsJson = keywords.map((k) => k.toJson()).toList();
    await prefs.setString(_keywordsKey, jsonEncode(keywordsJson));
  }

  // Charger les mots clés
  Future<List<Keyword>> loadKeywords() async {
    final prefs = await SharedPreferences.getInstance();
    final keywordsString = prefs.getString(_keywordsKey);

    if (keywordsString == null || keywordsString.isEmpty) {
      return [];
    }

    final List<dynamic> keywordsJson = jsonDecode(keywordsString);
    return keywordsJson.map((json) => Keyword.fromJson(json)).toList();
  }

  // Ajouter un mot clé
  Future<void> addKeyword(Keyword keyword) async {
    final keywords = await loadKeywords();
    keywords.add(keyword);
    await saveKeywords(keywords);

    // Ajouter un premier point de tracking
    await addTracking(KeywordTracking(
      keywordId: keyword.id,
      position: keyword.currentPosition,
      date: keyword.lastUpdated,
      searchVolume: keyword.searchVolume,
    ));
  }

  // Mettre à jour un mot clé
  Future<void> updateKeyword(Keyword keyword) async {
    final keywords = await loadKeywords();
    final index = keywords.indexWhere((k) => k.id == keyword.id);

    if (index != -1) {
      // Sauvegarder l'ancienne position
      final oldKeyword = keywords[index];
      final updatedKeyword = keyword.copyWith(
        previousPosition: oldKeyword.currentPosition,
      );

      keywords[index] = updatedKeyword;
      await saveKeywords(keywords);

      // Ajouter un point de tracking
      await addTracking(KeywordTracking(
        keywordId: keyword.id,
        position: keyword.currentPosition,
        date: keyword.lastUpdated,
        searchVolume: keyword.searchVolume,
      ));
    }
  }

  // Supprimer un mot clé
  Future<void> deleteKeyword(String id) async {
    final keywords = await loadKeywords();
    keywords.removeWhere((k) => k.id == id);
    await saveKeywords(keywords);

    // Supprimer aussi les trackings associés
    final trackings = await loadTrackings();
    trackings.removeWhere((t) => t.keywordId == id);
    await saveTrackings(trackings);
  }

  // Sauvegarder les trackings
  Future<void> saveTrackings(List<KeywordTracking> trackings) async {
    final prefs = await SharedPreferences.getInstance();
    final trackingsJson = trackings.map((t) => t.toJson()).toList();
    await prefs.setString(_trackingKey, jsonEncode(trackingsJson));
  }

  // Charger tous les trackings
  Future<List<KeywordTracking>> loadTrackings() async {
    final prefs = await SharedPreferences.getInstance();
    final trackingsString = prefs.getString(_trackingKey);

    if (trackingsString == null || trackingsString.isEmpty) {
      return [];
    }

    final List<dynamic> trackingsJson = jsonDecode(trackingsString);
    return trackingsJson.map((json) => KeywordTracking.fromJson(json)).toList();
  }

  // Charger les trackings d'un mot clé spécifique
  Future<List<KeywordTracking>> loadTrackingsForKeyword(String keywordId) async {
    final allTrackings = await loadTrackings();
    return allTrackings.where((t) => t.keywordId == keywordId).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Ajouter un tracking
  Future<void> addTracking(KeywordTracking tracking) async {
    final trackings = await loadTrackings();
    trackings.add(tracking);
    await saveTrackings(trackings);
  }

  // Effacer toutes les données (pour reset)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keywordsKey);
    await prefs.remove(_trackingKey);
  }
}
