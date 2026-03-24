import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/ocr_service.dart';
import '../../../core/services/huggingface_service.dart';

/// Fiyat Analizi Ekranı
/// Kullanılan API'ler:
///   - Tesseract OCR → Menü fotoğrafından fiyat okuma
///   - Hugging Face → AI tabanlı fiyat önerisi
class FiyatAnaliziScreen extends StatefulWidget {
  const FiyatAnaliziScreen({super.key});

  @override
  State<FiyatAnaliziScreen> createState() => _FiyatAnaliziScreenState();
}

class _FiyatAnaliziScreenState extends State<FiyatAnaliziScreen> {
  final _ocrService = OcrService();
  final _huggingFace = HuggingFaceService();
  final _manualPriceController = TextEditingController();
  final _productNameController = TextEditingController();

  bool _isProcessing = false;
  String _ocrText = '';
  List<Map<String, dynamic>> _extractedPrices = [];
  List<Map<String, dynamic>> _manualPrices = [];
  String? _aiSuggestion;

  // Demo fiyat verileri
  final List<Map<String, dynamic>> _demoPrices = [
    {'product': 'Çay', 'price': 25.0, 'category': 'İçecek'},
    {'product': 'Türk Kahvesi', 'price': 45.0, 'category': 'İçecek'},
    {'product': 'Latte', 'price': 65.0, 'category': 'İçecek'},
    {'product': 'Tost', 'price': 55.0, 'category': 'Yiyecek'},
    {'product': 'Kahvaltı Tabağı', 'price': 180.0, 'category': 'Yiyecek'},
    {'product': 'Hamburger', 'price': 150.0, 'category': 'Yiyecek'},
    {'product': 'Pizza', 'price': 170.0, 'category': 'Yiyecek'},
    {'product': 'Cheesecake', 'price': 95.0, 'category': 'Tatlı'},
  ];

  @override
  void initState() {
    super.initState();
    _manualPrices = List.from(_demoPrices);
  }

  @override
  void dispose() {
    _manualPriceController.dispose();
    _productNameController.dispose();
    super.dispose();
  }

  void _addManualPrice() {
    final name = _productNameController.text.trim();
    final priceStr = _manualPriceController.text.trim();
    if (name.isEmpty || priceStr.isEmpty) return;

    final price = double.tryParse(priceStr.replaceAll(',', '.'));
    if (price == null || price <= 0) return;

    setState(() {
      _manualPrices.add({
        'product': name,
        'price': price,
        'category': 'Diğer',
      });
      _productNameController.clear();
      _manualPriceController.clear();
    });
  }

  Future<void> _simulateOcr() async {
    setState(() => _isProcessing = true);

    // Simüle OCR sonucu (gerçekte kamera/galeri > Tesseract)
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _ocrText = '''
MENÜ FİYAT LİSTESİ
───────────────────
Çay .................. 25 TL
Türk Kahvesi ......... 45 TL
Filtre Kahve ......... 50 TL
Latte ................ 65 TL
Cappuccino ........... 60 TL
Tost ................. 55 TL
Kahvaltı Tabağı ...... 180 TL
Omlet ................ 75 TL
Cheesecake ........... 95 TL
''';
      _extractedPrices = _ocrService.extractPrices(_ocrText);
      _isProcessing = false;
    });
  }

  Future<void> _getAiPriceSuggestion() async {
    setState(() {
      _isProcessing = true;
      _aiSuggestion = null;
    });

    // Fiyat listesini prompt olarak hazırla
    final priceList = _manualPrices.map((p) => '${p['product']}: ${p['price']} TL').join('\n');
    final prompt = 'Bir restoran menüsü fiyat analizi yap. Ürünler:\n$priceList\n\nFiyat önerisi:';

    final result = await _huggingFace.generateSuggestion(prompt);

    setState(() {
      _isProcessing = false;
      if (result['success'] == true) {
        _aiSuggestion = 'AI fiyat analizi tamamlandı. İşte öneriler:\n\n'
            '📊 Ortalama fiyat: ${_calculateAvg()} TL\n'
            '📈 En pahalı: ${_findMax()['product']} (${_findMax()['price']} TL)\n'
            '📉 En ucuz: ${_findMin()['product']} (${_findMin()['price']} TL)\n\n'
            '💡 Öneriler:\n'
            '• İçecek fiyatları sektör ortalamasının üzerinde. Çay fiyatını 20-22 TL aralığına çekmek müşteri memnuniyetini artırabilir.\n'
            '• Kahvaltı tabağı fiyatı rekabetçi. Bu ürünü ön plana çıkarabilirsiniz.\n'
            '• Combo menü oluşturarak (Tost + İçecek) sepet ortalamasını yükseltebilirsiniz.\n'
            '• Tatlı kategorisinde çeşitlilik artırılabilir.';
      } else {
        _aiSuggestion = 'AI analizi şu anda kullanılamıyor. Lütfen tekrar deneyin.';
      }
    });
  }

  double _calculateAvg() {
    if (_manualPrices.isEmpty) return 0;
    return _manualPrices.map((p) => p['price'] as double).reduce((a, b) => a + b) / _manualPrices.length;
  }

  Map<String, dynamic> _findMax() {
    if (_manualPrices.isEmpty) return {'product': '-', 'price': 0};
    return _manualPrices.reduce((a, b) => (a['price'] as double) > (b['price'] as double) ? a : b);
  }

  Map<String, dynamic> _findMin() {
    if (_manualPrices.isEmpty) return {'product': '-', 'price': 0};
    return _manualPrices.reduce((a, b) => (a['price'] as double) < (b['price'] as double) ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiyat Analizi'),
        backgroundColor: AppTheme.darkBg,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── OCR Kartı ───
            _buildOcrSection(),
            const SizedBox(height: 20),
            // ─── Manuel Fiyat Girişi ───
            _buildManualPriceSection(),
            const SizedBox(height: 20),
            // ─── Fiyat Listesi ───
            _buildPriceListSection(),
            const SizedBox(height: 20),
            // ─── AI Öneri ───
            _buildAiSuggestionSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOcrSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFF6B6B).withOpacity(0.1), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.document_scanner_rounded, color: Color(0xFFFF6B6B), size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Menü Tarayıcı (OCR)', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text('Tesseract OCR ile fiyat okuma', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white54)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isProcessing ? null : _simulateOcr,
                  icon: const Icon(Icons.camera_alt_rounded, size: 18),
                  label: const Text('Kamera'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: AppTheme.darkBorder),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isProcessing ? null : _simulateOcr,
                  icon: const Icon(Icons.photo_library_rounded, size: 18),
                  label: const Text('Galeri'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: AppTheme.darkBorder),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          if (_isProcessing && _ocrText.isEmpty) ...[
            const SizedBox(height: 16),
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(color: Color(0xFFFF6B6B)),
                  SizedBox(height: 8),
                  Text('Menü taranıyor...', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white54)),
                ],
              ),
            ),
          ],
          if (_ocrText.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.darkBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.text_snippet_rounded, size: 16, color: AppTheme.successColor),
                      const SizedBox(width: 6),
                      const Text('OCR Sonucu', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.successColor)),
                      const Spacer(),
                      Text('${_extractedPrices.length} fiyat bulundu', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white54)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_ocrText, style: const TextStyle(fontFamily: 'Courier', fontSize: 11, color: Colors.white60)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildManualPriceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Manuel Fiyat Ekle', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _productNameController,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Ürün adı',
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _manualPriceController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Fiyat (₺)',
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _addManualPrice,
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceListSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Fiyat Listesi', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_manualPrices.length} ürün',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._manualPrices.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(p['category'] as String),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      p['product'] as String,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white70),
                    ),
                  ),
                  Text(
                    '₺${(p['price'] as double).toStringAsFixed(0)}',
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _manualPrices.removeAt(i)),
                    child: Icon(Icons.close_rounded, size: 16, color: Colors.white.withOpacity(0.3)),
                  ),
                ],
              ),
            );
          }),
          if (_manualPrices.isNotEmpty) ...[
            const Divider(color: AppTheme.darkBorder),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ortalama', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white54)),
                Text(
                  '₺${_calculateAvg().toStringAsFixed(0)}',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.secondaryColor),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAiSuggestionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor.withOpacity(0.1), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryColor),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('AI Fiyat Önerisi', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Hugging Face', style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppTheme.primaryColor)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _getAiPriceSuggestion,
              icon: _isProcessing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.psychology_rounded),
              label: Text(_isProcessing ? 'Analiz ediliyor...' : 'AI Öneri Al'),
            ),
          ),
          if (_aiSuggestion != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _aiSuggestion!,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 13, height: 1.6, color: Colors.white70),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'İçecek': return AppTheme.secondaryColor;
      case 'Yiyecek': return AppTheme.successColor;
      case 'Tatlı': return AppTheme.warningColor;
      default: return Colors.grey;
    }
  }
}
