import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants/api_constants.dart';

/// Hugging Face Inference API Servisi
/// Kullanıldığı ekranlar: Yorum Analizi, Fiyat Önerisi, Kampanya Önerileri
///
/// Türkçe BERT modelleri ile:
/// - Duygu analizi (sentiment)
/// - Tema/kategori çıkarma (NER)
/// - Metin üretimi (kampanya/öneri)
class HuggingFaceService {
  static final HuggingFaceService _instance = HuggingFaceService._();
  factory HuggingFaceService() => _instance;
  HuggingFaceService._();

  /// Duygu analizi yap (Pozitif / Negatif / Nötr)
  /// Kullanım: Yorum Analizi ekranında müşteri yorumlarını analiz etmek için
  Future<Map<String, dynamic>> analyzeSentiment(String text) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.hfSentimentUrl),
        headers: ApiConstants.huggingFaceHeaders,
        body: jsonEncode({'inputs': text}),
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'results': data,
          'model': ApiConstants.hfSentimentModel,
        };
      } else if (response.statusCode == 503) {
        // Model yükleniyor — tekrar dene
        return {
          'success': false,
          'error': 'Model yükleniyor, lütfen birkaç saniye bekleyin...',
          'retry': true,
        };
      } else {
        return {
          'success': false,
          'error': 'Analiz hatası: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Bağlantı hatası: ${e.toString()}',
      };
    }
  }

  /// Toplu yorum analizi (birden fazla yorum)
  /// Kullanım: Dashboard'da toplu analiz raporu oluşturmak için
  Future<Map<String, dynamic>> analyzeBatch(List<String> reviews) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.hfSentimentUrl),
        headers: ApiConstants.huggingFaceHeaders,
        body: jsonEncode({'inputs': reviews}),
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'results': data};
      } else {
        return {
          'success': false,
          'error': 'Toplu analiz hatası: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Bağlantı hatası: ${e.toString()}',
      };
    }
  }

  /// Kampanya/fiyat önerisi oluştur
  /// Kullanım: Kampanya Önerileri ve Fiyat Önerisi ekranlarında
  Future<Map<String, dynamic>> generateSuggestion(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.hfTextGenUrl),
        headers: ApiConstants.huggingFaceHeaders,
        body: jsonEncode({
          'inputs': prompt,
          'parameters': {
            'max_length': 200,
            'temperature': 0.7,
          },
        }),
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'results': data};
      } else {
        return {
          'success': false,
          'error': 'Öneri oluşturma hatası: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Bağlantı hatası: ${e.toString()}',
      };
    }
  }
}
