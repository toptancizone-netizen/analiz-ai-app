/// OCR Servisi (Web-Safe)
/// Kullanıldığı ekranlar: Fiyat Analizi
///
/// Web'de: Regex ile fiyat ayıklama
/// Mobile'da: Tesseract entegrasyonu (gelecek sürüm)
class OcrService {
  static const String _tesseractLanguage = 'tur';
  static final OcrService _instance = OcrService._();
  factory OcrService() => _instance;
  OcrService._();

  /// Fotoğraftan metin çıkar (OCR)
  /// Kullanım: Fiyat Analizi ekranında menü/etiket fotoğrafı yüklenince
  Future<Map<String, dynamic>> extractText(String imagePath) async {
    try {
      // flutter_tesseract_ocr paketi henüz entegre edilmediğinde
      // placeholder olarak çalışır
      // Gerçek implementasyon:
      // final text = await FlutterTesseractOcr.extractText(
      //   imagePath,
      //   language: ApiConstants.tesseractLanguage,
      // );

      return {
        'success': true,
        'text': '',
        'language': _tesseractLanguage,
        'prices': <Map<String, dynamic>>[],
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'OCR hatası: ${e.toString()}',
      };
    }
  }

  /// Metinden fiyatları çıkar (regex ile)
  /// OCR sonucundan TL fiyatlarını bulur
  List<Map<String, dynamic>> extractPrices(String text) {
    final prices = <Map<String, dynamic>>[];

    // Türkçe fiyat formatları: 45 TL, 45,50 TL, ₺45, 45.50₺, 45,50
    final priceRegex = RegExp(
      r'(\d{1,4}[.,]\d{2}|\d{1,4})\s*(?:TL|₺|tl)',
      caseSensitive: false,
    );

    for (final match in priceRegex.allMatches(text)) {
      final priceStr = match.group(1)?.replaceAll(',', '.') ?? '0';
      final price = double.tryParse(priceStr) ?? 0;
      if (price > 0) {
        prices.add({
          'value': price,
          'original': match.group(0),
          'position': match.start,
        });
      }
    }

    return prices;
  }
}
