import 'package:flutter/material.dart';

/// Dashboard veri yönetimi
class DashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  // Özet istatistikler
  int _totalReviews = 0;
  int _competitorCount = 0;
  double _sentimentScore = 0.0;
  int _campaignSuggestions = 0;
  String _lastAnalysisDate = '';

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalReviews => _totalReviews;
  int get competitorCount => _competitorCount;
  double get sentimentScore => _sentimentScore;
  int get campaignSuggestions => _campaignSuggestions;
  String get lastAnalysisDate => _lastAnalysisDate;

  /// Dashboard verilerini yükle
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simüle veri — backend API entegrasyonu sonra eklenecek
      await Future.delayed(const Duration(milliseconds: 800));

      _totalReviews = 156;
      _competitorCount = 12;
      _sentimentScore = 78.5;
      _campaignSuggestions = 5;
      _lastAnalysisDate = 'Bugün 14:30';

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Veri yüklenirken hata: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
}
