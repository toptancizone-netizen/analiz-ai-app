import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

/// İyzico Ödeme Servisi
/// Kullanıldığı ekranlar: Abonelik, Ödeme, Plan Seçimi
///
/// NOT: İyzico API çağrıları güvenlik nedeniyle BACKEND üzerinden yapılmalıdır.
/// Bu servis, backend'deki İyzico endpoint'lerine Flutter'dan istek yapar.
/// Doğrudan İyzico API'sine istemciden çağrı yapılmamalıdır.
class IyzicoService {
  static final IyzicoService _instance = IyzicoService._();
  factory IyzicoService() => _instance;
  IyzicoService._();

  String get _backendBaseUrl => ApiConstants.backendBaseUrl;

  /// Abonelik planlarını getir
  Future<Map<String, dynamic>> getSubscriptionPlans() async {
    try {
      final response = await http.get(
        Uri.parse('$_backendBaseUrl/subscription/plans'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'plans': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Plan yükleme hatası: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Bağlantı hatası: ${e.toString()}',
      };
    }
  }

  /// Ödeme başlat (3D Secure)
  /// Backend bunu İyzico 3D Secure initialize endpoint'ine yönlendirir
  Future<Map<String, dynamic>> initializePayment({
    required String planId,
    required String cardHolderName,
    required String cardNumber,
    required String expireMonth,
    required String expireYear,
    required String cvc,
    int? installment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendBaseUrl/payment/initialize'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'planId': planId,
          'cardHolderName': cardHolderName,
          'cardNumber': cardNumber,
          'expireMonth': expireMonth,
          'expireYear': expireYear,
          'cvc': cvc,
          'installment': installment ?? 1,
        }),
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Ödeme başlatma hatası: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Bağlantı hatası: ${e.toString()}',
      };
    }
  }

  /// Taksit seçeneklerini getir
  Future<Map<String, dynamic>> getInstallmentOptions({
    required String binNumber, // Kart numarasının ilk 6 hanesi
    required double price,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendBaseUrl/payment/installments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'binNumber': binNumber,
          'price': price,
        }),
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'installments': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Taksit bilgisi hatası: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Bağlantı hatası: ${e.toString()}',
      };
    }
  }

  /// Abonelik durumunu kontrol et
  Future<Map<String, dynamic>> checkSubscriptionStatus(
      String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_backendBaseUrl/subscription/status/$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'subscription': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Abonelik kontrol hatası: ${response.statusCode}',
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
