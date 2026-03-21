/// ═══════════════════════════════════════════════════════════════════════════
/// AnalizAI — Merkezi API Yapılandırma Dosyası
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Tüm ücretsiz API endpoint'leri, token'ları ve anahtarları burada tanımlanır.
/// Ücretli Google API'ler yerine ücretsiz alternatifler kullanılmaktadır:
///
///   Google Maps     → OpenStreetMap Nominatim
///   Gemini AI       → Hugging Face Inference API
///   PayTR           → İyzico Sandbox
///   Google Auth     → Firebase Authentication (ücretsiz katman)
///   Cloud Vision    → Tesseract OCR (lokal)
///
/// ─────────────────────────── API KULLANIM HARİTASI ───────────────────────
///
///   Nominatim      → Rakipler ekranı, Mahalle Trendleri ekranı
///   Hugging Face   → Yorum Analizi, Fiyat Önerisi, Kampanya Önerisi
///   İyzico         → Abonelik ve Ödeme ekranları
///   Firebase       → Giriş (Google Sign-In), Bildirimler, Analytics
///   Tesseract      → Fiyat Analizi ekranı (menü fotoğrafı → fiyat okuma)
///
/// ═══════════════════════════════════════════════════════════════════════════

class ApiConstants {
  // Bu sınıf instance'lanmamalı
  ApiConstants._();

  // ═══════════════════════════════════════════════════════════════════════
  // BACKEND — Spring Boot Server
  // ═══════════════════════════════════════════════════════════════════════

  static const String backendBaseUrl = 'http://10.0.2.2:8080/api'; // Android emulator
  static const String backendBaseUrlIos = 'http://localhost:8080/api'; // iOS simulator
  static const String backendBaseUrlWeb = 'http://localhost:8080/api'; // Web

  // ═══════════════════════════════════════════════════════════════════════
  // 1. NOMINATIM (OpenStreetMap) — Harita / Rakip Bulma / Adres Arama
  //    Kullanıldığı ekranlar: Rakipler, Mahalle Trendleri
  // ═══════════════════════════════════════════════════════════════════════

  static const String nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
  static const String nominatimSearchUrl = '$nominatimBaseUrl/search';
  static const String nominatimReverseUrl = '$nominatimBaseUrl/reverse';
  static const String nominatimUserAgent = 'AnalizAI/1.0 (contact@analizai.com)';

  /// Nominatim parametreleri
  static const String nominatimFormat = 'json';
  static const String nominatimCountryCodes = 'tr'; // Sadece Türkiye
  static const int nominatimSearchLimit = 20;

  // ═══════════════════════════════════════════════════════════════════════
  // 2. HUGGING FACE — AI Analiz (Yorum, Duygu, Tema, Öneri, Kampanya)
  //    Kullanıldığı ekranlar: Yorum Analizi, Fiyat Önerisi, Kampanya Önerileri
  // ═══════════════════════════════════════════════════════════════════════

  static const String huggingFaceBaseUrl = 'https://api-inference.huggingface.co/models';
  static const String huggingFaceToken = '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';

  /// Türkçe BERT Modelleri
  static const String hfSentimentModel = 'savasy/bert-base-turkish-sentiment-cased';
  static const String hfNerModel = 'dbmdz/bert-base-turkish-cased';
  static const String hfTextGenModel = 'dbmdz/bert-base-turkish-cased';

  /// Model URL'leri (tam endpoint)
  static String get hfSentimentUrl => '$huggingFaceBaseUrl/$hfSentimentModel';
  static String get hfNerUrl => '$huggingFaceBaseUrl/$hfNerModel';
  static String get hfTextGenUrl => '$huggingFaceBaseUrl/$hfTextGenModel';

  /// Hugging Face istek başlıkları
  static Map<String, String> get huggingFaceHeaders => {
        'Authorization': 'Bearer $huggingFaceToken',
        'Content-Type': 'application/json',
      };

  // ═══════════════════════════════════════════════════════════════════════
  // 3. İYZİCO SANDBOX — Ödeme / Abonelik
  //    Kullanıldığı ekranlar: Abonelik, Ödeme, Plan Seçimi
  // ═══════════════════════════════════════════════════════════════════════

  static const String iyzicoBaseUrl = 'https://sandbox-api.iyzipay.com';
  static const String iyzicoApiKey = 'XU2fn65Sc2w8Hzq8';
  static const String iyzicoSecretKey = 'AnjqBR5SWprG9CTa';
  static const String iyzicoMerchantId = '563121';

  /// İyzico endpoint'leri (backend üzerinden proxy ile çağrılacak)
  static const String iyzicoPaymentUrl = '$iyzicoBaseUrl/payment/auth';
  static const String iyzicoSubscriptionUrl = '$iyzicoBaseUrl/v2/subscription';
  static const String iyzicoInstallmentUrl = '$iyzicoBaseUrl/payment/iyzipos/installment';
  static const String iyzico3DInitUrl = '$iyzicoBaseUrl/payment/3dsecure/initialize';

  // ═══════════════════════════════════════════════════════════════════════
  // 4. FIREBASE — Google Sign-In + Push + Analytics
  //    Kullanıldığı ekranlar: Giriş, tüm uygulama (analytics), Bildirimler
  // ═══════════════════════════════════════════════════════════════════════

  static const String firebaseApiKey = 'AIzaSyCcWbhpnBuub2j6RBVdjNBjpb7knlLNPwI';
  static const String firebaseProjectId = 'analizai';
  static const String firebaseAppId = '1:4300328367:web:099e8695a8ab224155335a';
  static const String firebaseMessagingSenderId = '4300328367';
  static const String firebaseStorageBucket = 'analizai.firebasestorage.app';

  // ═══════════════════════════════════════════════════════════════════════
  // 5. TESSERACT OCR — Menü Fotoğrafından Fiyat Okuma
  //    Kullanıldığı ekranlar: Fiyat Analizi
  // ═══════════════════════════════════════════════════════════════════════

  static const String tesseractLanguage = 'tur'; // Türkçe
  static const String tesseractFallbackLanguage = 'eng'; // İngilizce yedek

  // ═══════════════════════════════════════════════════════════════════════
  // UYGULAMA SABİTLERİ
  // ═══════════════════════════════════════════════════════════════════════

  /// Cache süreleri (saniye)
  static const int cacheDurationShort = 300;     // 5 dakika
  static const int cacheDurationMedium = 1800;   // 30 dakika
  static const int cacheDurationLong = 86400;    // 24 saat

  /// API istek limitleri
  static const int maxRetryCount = 3;
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration nominatimRequestDelay = Duration(seconds: 1); // Rate limit

  /// Abonelik planları
  static const String freePlanId = 'free';
  static const String proPlanId = 'pro';
  static const String premiumPlanId = 'premium';

  /// Abonelik fiyatları (TL)
  static const double proPlanPrice = 149.99;
  static const double premiumPlanPrice = 299.99;
}
