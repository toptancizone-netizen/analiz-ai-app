import 'package:flutter/material.dart';

/// Dashboard veri yönetimi — İşletme türüne göre dinamik veriler
class DashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  // Özet istatistikler
  int _totalReviews = 0;
  int _competitorCount = 0;
  double _sentimentScore = 0.0;
  int _campaignSuggestions = 0;
  String _analysisStatus = '';
  List<Map<String, dynamic>> _recentInsights = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalReviews => _totalReviews;
  int get competitorCount => _competitorCount;
  double get sentimentScore => _sentimentScore;
  int get campaignSuggestions => _campaignSuggestions;
  String get analysisStatus => _analysisStatus;
  List<Map<String, dynamic>> get recentInsights => _recentInsights;

  /// İşletme türüne göre dashboard verilerini oluştur
  Future<void> loadDashboardData({
    String businessType = 'restoran',
    String location = 'İstanbul',
  }) async {
    _isLoading = true;
    _error = null;
    _analysisStatus = 'İşletmeniz analiz ediliyor...';
    notifyListeners();

    try {
      // Aşama 1: Konum analizi
      _analysisStatus = '📍 $location bölgesi taranıyor...';
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 600));

      // Aşama 2: Rakip tarama
      _analysisStatus = '🔍 Rakipler bulunuyor...';
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 500));

      // Aşama 3: Yorum analizi
      _analysisStatus = '🧠 AI analiz çalıştırılıyor...';
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 500));

      // İşletme türüne göre simüle veriler
      final data = _generateBusinessData(businessType, location);
      _totalReviews = data['totalReviews'] as int;
      _competitorCount = data['competitorCount'] as int;
      _sentimentScore = data['sentimentScore'] as double;
      _campaignSuggestions = data['campaignSuggestions'] as int;
      _recentInsights = List<Map<String, dynamic>>.from(data['insights'] as List);

      _analysisStatus = '✅ Analiz tamamlandı!';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Veri yüklenirken hata: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _generateBusinessData(String businessType, String location) {
    switch (businessType) {
      case 'restoran':
        return {
          'totalReviews': 234,
          'competitorCount': 18,
          'sentimentScore': 76.5,
          'campaignSuggestions': 7,
          'insights': [
            {'icon': '⚠️', 'title': 'Servis hızı', 'text': 'Müşterilerin %32\'si yavaş servisten şikayetçi', 'type': 'warning'},
            {'icon': '✅', 'title': 'Lezzet kalitesi', 'text': 'Yemek kalitesi yorumların %85\'inde olumlu', 'type': 'success'},
            {'icon': '💡', 'title': 'Fırsat', 'text': '$location bölgesinde vegan menü sunan rakip yok', 'type': 'tip'},
            {'icon': '📊', 'title': 'Fiyat', 'text': 'Ortalama fiyatlarınız bölge ortalamasının %12 altında', 'type': 'info'},
          ],
        };
      case 'kafe':
        return {
          'totalReviews': 189,
          'competitorCount': 24,
          'sentimentScore': 82.0,
          'campaignSuggestions': 5,
          'insights': [
            {'icon': '✅', 'title': 'Ambiyans', 'text': 'Müşterilerin %90\'ı ortam atmosferini beğeniyor', 'type': 'success'},
            {'icon': '⚠️', 'title': 'Fiyatlama', 'text': 'Kahve fiyatları bölge ortalamasının %18 üstünde', 'type': 'warning'},
            {'icon': '💡', 'title': 'Trend', 'text': '$location\'da specialty coffee talebi %40 arttı', 'type': 'tip'},
            {'icon': '📊', 'title': 'Rekabet', 'text': '500m yarıçapında 8 rakip kafe var', 'type': 'info'},
          ],
        };
      case 'market':
        return {
          'totalReviews': 312,
          'competitorCount': 9,
          'sentimentScore': 71.0,
          'campaignSuggestions': 8,
          'insights': [
            {'icon': '⚠️', 'title': 'Fiyat algısı', 'text': 'Müşterilerin %45\'i fiyatları yüksek buluyor', 'type': 'warning'},
            {'icon': '✅', 'title': 'Ürün çeşitliliği', 'text': 'Ürün çeşidi yorumların %78\'inde olumlu', 'type': 'success'},
            {'icon': '💡', 'title': 'Fırsat', 'text': '$location\'da organik ürün talebi hızla artıyor', 'type': 'tip'},
            {'icon': '📊', 'title': 'Sadakat', 'text': 'Tekrar eden müşteri oranı %62', 'type': 'info'},
          ],
        };
      case 'kuafor':
        return {
          'totalReviews': 156,
          'competitorCount': 14,
          'sentimentScore': 84.5,
          'campaignSuggestions': 6,
          'insights': [
            {'icon': '✅', 'title': 'Müşteri memnuniyeti', 'text': 'Hizmet kalitesi %84 oranında olumlu değerlendiriliyor', 'type': 'success'},
            {'icon': '⚠️', 'title': 'Randevu', 'text': 'Müşterilerin %28\'i randevu bekleme süresi uzun diyor', 'type': 'warning'},
            {'icon': '💡', 'title': 'Trend', 'text': '$location\'da erkek bakım hizmetleri %55 arttı', 'type': 'tip'},
            {'icon': '📊', 'title': 'Fiyat', 'text': 'Fiyatlarınız bölge ortalamasıyla uyumlu', 'type': 'info'},
          ],
        };
      default:
        return {
          'totalReviews': 128,
          'competitorCount': 11,
          'sentimentScore': 75.0,
          'campaignSuggestions': 4,
          'insights': [
            {'icon': '✅', 'title': 'Genel durum', 'text': 'İşletmeniz bölge ortalamasının üzerinde performans gösteriyor', 'type': 'success'},
            {'icon': '💡', 'title': 'Öneri', 'text': 'Sosyal medya varlığınızı güçlendirmeniz önerilir', 'type': 'tip'},
            {'icon': '📊', 'title': 'Rekabet', 'text': '$location bölgesinde $businessType kategorisinde 11 rakip var', 'type': 'info'},
          ],
        };
    }
  }
}
