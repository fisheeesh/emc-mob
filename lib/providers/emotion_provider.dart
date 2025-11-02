import 'package:flutter/material.dart';
import 'package:emc_mob/models/emotion_model.dart';
import 'package:emc_mob/services/emotion_service.dart';

class EmotionProvider with ChangeNotifier {
  List<EmotionCategory> _categories = [];
  bool _isLoading = false;
  bool _hasError = false;

  List<EmotionCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  /// Load emotions instantly from cache/fallback
  Future<void> loadEmotions() async {
    _categories = await EmotionService.getEmotionsInstant();
    notifyListeners();
  }

  /// Sync in background (no UI blocking)
  Future<void> syncInBackground(String? accessToken) async {
    if (accessToken == null) {
      print('No access token available, skipping sync');
      return;
    }

    await EmotionService.syncEmotionsInBackground(accessToken);
    // Reload from cache after sync
    _categories = await EmotionService.getEmotionsInstant();
    notifyListeners();
  }

  /// Manual refresh with loading indicator
  Future<void> refresh(String? accessToken) async {
    if (accessToken == null) {
      print('No access token available, cannot refresh');
      return;
    }

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      _categories = await EmotionService.forceRefresh(accessToken);
      _hasError = false;
    } catch (e) {
      _hasError = true;
      print('Error refreshing emotions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get emotions by category title
  List<Map<String, dynamic>> getEmotionsByCategory(String categoryTitle) {
    final category = _categories.firstWhere(
          (cat) => cat.title.toLowerCase() == categoryTitle.toLowerCase(),
      orElse: () => EmotionCategory(title: '', emotions: []),
    );

    return category.emotions
        .map((e) => {'icon': e.icon, 'label': e.label})
        .toList();
  }

  /// Get category index by title
  int getCategoryIndex(String categoryTitle) {
    return _categories.indexWhere(
          (cat) => cat.title.toLowerCase() == categoryTitle.toLowerCase(),
    );
  }
}