import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

/// OpenStreetMap Nominatim API Servisi
/// Kullanıldığı ekranlar: Rakip Analizi, Mahalle Trendleri
///
/// Özellikler:
/// - Çevredeki rakip işletmeleri bulma
/// - Adres autocomplete
/// - Ters geocoding (koordinat → adres)
/// - Mahalle/bölge bazlı arama
class NominatimService {
  static final NominatimService _instance = NominatimService._();
  factory NominatimService() => _instance;
  NominatimService._();

  DateTime? _lastRequestTime;

  /// Rate limiting — Nominatim 1 istek/saniye kuralına uy
  Future<void> _respectRateLimit() async {
    if (_lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);
      if (elapsed < ApiConstants.nominatimRequestDelay) {
        await Future.delayed(ApiConstants.nominatimRequestDelay - elapsed);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  /// Rakip işletmeleri bul (lokasyon bazlı arama)
  /// Kullanım: Rakip Analizi ekranında çevredeki benzer işletmeleri bulmak için
  Future<Map<String, dynamic>> searchCompetitors({
    required String query,
    required double lat,
    required double lon,
    double radiusKm = 2.0,
  }) async {
    await _respectRateLimit();

    try {
      final uri = Uri.parse(ApiConstants.nominatimSearchUrl).replace(
        queryParameters: {
          'q': query,
          'format': ApiConstants.nominatimFormat,
          'countrycodes': ApiConstants.nominatimCountryCodes,
          'limit': ApiConstants.nominatimSearchLimit.toString(),
          'viewbox': _calculateViewbox(lat, lon, radiusKm),
          'bounded': '1',
          'addressdetails': '1',
          'extratags': '1',
        },
      );

      final response = await http.get(uri, headers: {
        'User-Agent': ApiConstants.nominatimUserAgent,
        'Accept-Language': 'tr',
      }).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {
          'success': true,
          'results': data,
          'count': data.length,
        };
      } else {
        return {
          'success': false,
          'error': 'Arama hatası: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Bağlantı hatası: ${e.toString()}',
      };
    }
  }

  /// Adres arama (autocomplete)
  /// Kullanım: İşletme adres girişi ve konum seçimi için
  Future<Map<String, dynamic>> searchAddress(String query) async {
    await _respectRateLimit();

    try {
      final uri = Uri.parse(ApiConstants.nominatimSearchUrl).replace(
        queryParameters: {
          'q': query,
          'format': ApiConstants.nominatimFormat,
          'countrycodes': ApiConstants.nominatimCountryCodes,
          'limit': '10',
          'addressdetails': '1',
        },
      );

      final response = await http.get(uri, headers: {
        'User-Agent': ApiConstants.nominatimUserAgent,
        'Accept-Language': 'tr',
      }).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {'success': true, 'results': data};
      } else {
        return {
          'success': false,
          'error': 'Adres arama hatası: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Bağlantı hatası: ${e.toString()}',
      };
    }
  }

  /// Ters geocoding (koordinattan adres bul)
  /// Kullanım: GPS konumu kullanarak işletmenin mahalle/semt bilgisini bulmak
  Future<Map<String, dynamic>> reverseGeocode(
      double lat, double lon) async {
    await _respectRateLimit();

    try {
      final uri = Uri.parse(ApiConstants.nominatimReverseUrl).replace(
        queryParameters: {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'format': ApiConstants.nominatimFormat,
          'addressdetails': '1',
          'zoom': '18',
        },
      );

      final response = await http.get(uri, headers: {
        'User-Agent': ApiConstants.nominatimUserAgent,
        'Accept-Language': 'tr',
      }).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'result': data};
      } else {
        return {
          'success': false,
          'error': 'Geocoding hatası: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Bağlantı hatası: ${e.toString()}',
      };
    }
  }

  /// Bounding box hesapla (merkez + yarıçap → viewbox)
  String _calculateViewbox(double lat, double lon, double radiusKm) {
    // 1 derece ≈ 111 km
    final delta = radiusKm / 111.0;
    final west = lon - delta;
    final south = lat - delta;
    final east = lon + delta;
    final north = lat + delta;
    return '$west,$north,$east,$south';
  }
}
