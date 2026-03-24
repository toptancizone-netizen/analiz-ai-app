import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/huggingface_service.dart';

/// Yorum Analizi Ekranı
/// Kullanılan API: Hugging Face Inference (Türkçe BERT)
/// Müşteri yorumlarını AI ile analiz eder: duygu, tema, öneriler
class YorumAnaliziScreen extends StatefulWidget {
  const YorumAnaliziScreen({super.key});

  @override
  State<YorumAnaliziScreen> createState() => _YorumAnaliziScreenState();
}

class _YorumAnaliziScreenState extends State<YorumAnaliziScreen>
    with SingleTickerProviderStateMixin {
  final _yorumController = TextEditingController();
  final _huggingFace = HuggingFaceService();
  late TabController _tabController;

  bool _isAnalyzing = false;
  List<Map<String, dynamic>> _results = [];
  Map<String, int> _sentimentSummary = {'pozitif': 0, 'negatif': 0, 'nötr': 0};

  // Örnek yorumlar (demo amaçlı)
  final List<String> _sampleReviews = [
    'Yemekler çok lezzetliydi, tekrar geleceğiz kesinlikle!',
    'Servis çok yavaştı, 45 dakika bekledik.',
    'Fiyatlar makul ama porsiyon küçük geldi.',
    'Ortam harika, çok şık bir mekan dekorasyon süper.',
    'Garsonlar ilgisiz, sipariş unutuldu.',
    'Kahvaltı tabağı muhteşemdi, çeşit çok fazla.',
    'Tatlılar bayat geldi, hayal kırıklığı.',
    'Her şey mükemmeldi, 5 yıldız hak ediyor!',
    'Otopark sorunu var, park yeri bulamadık.',
    'Çocuk menüsü olması büyük artı.',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _yorumController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _analyzeSingleReview() async {
    final text = _yorumController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isAnalyzing = true);

    final result = await _huggingFace.analyzeSentiment(text);

    setState(() {
      _isAnalyzing = false;
      if (result['success'] == true) {
        _results.insert(0, {
          'text': text,
          'sentiment': _parseSentiment(result['results']),
          'confidence': _parseConfidence(result['results']),
          'timestamp': DateTime.now().toString(),
        });
        _updateSummary();
        _yorumController.clear();
      } else {
        // Hata durumunda da göster
        _results.insert(0, {
          'text': text,
          'sentiment': 'hata',
          'confidence': 0.0,
          'error': result['error'],
          'timestamp': DateTime.now().toString(),
        });
      }
    });
  }

  Future<void> _analyzeBatchReviews() async {
    setState(() {
      _isAnalyzing = true;
      _results.clear();
    });

    final result = await _huggingFace.analyzeBatch(_sampleReviews);

    setState(() {
      _isAnalyzing = false;
      if (result['success'] == true) {
        final batchResults = result['results'] as List<dynamic>? ?? [];
        for (int i = 0; i < _sampleReviews.length; i++) {
          final sentiment = i < batchResults.length
              ? _parseSentimentFromBatch(batchResults[i])
              : 'nötr';
          final confidence = i < batchResults.length
              ? _parseConfidenceFromBatch(batchResults[i])
              : 0.0;
          _results.add({
            'text': _sampleReviews[i],
            'sentiment': sentiment,
            'confidence': confidence,
            'timestamp': DateTime.now().toString(),
          });
        }
        _updateSummary();
      }
    });
  }

  String _parseSentiment(dynamic data) {
    try {
      if (data is List && data.isNotEmpty) {
        final firstResult = data[0];
        if (firstResult is List && firstResult.isNotEmpty) {
          final label = firstResult[0]['label']?.toString().toLowerCase() ?? '';
          if (label.contains('positive') || label.contains('pozitif')) return 'pozitif';
          if (label.contains('negative') || label.contains('negatif')) return 'negatif';
        } else if (firstResult is Map) {
          final label = firstResult['label']?.toString().toLowerCase() ?? '';
          if (label.contains('positive') || label.contains('pozitif')) return 'pozitif';
          if (label.contains('negative') || label.contains('negatif')) return 'negatif';
        }
      }
    } catch (_) {}
    return 'nötr';
  }

  double _parseConfidence(dynamic data) {
    try {
      if (data is List && data.isNotEmpty) {
        final firstResult = data[0];
        if (firstResult is List && firstResult.isNotEmpty) {
          return (firstResult[0]['score'] as num?)?.toDouble() ?? 0.0;
        } else if (firstResult is Map) {
          return (firstResult['score'] as num?)?.toDouble() ?? 0.0;
        }
      }
    } catch (_) {}
    return 0.0;
  }

  String _parseSentimentFromBatch(dynamic item) {
    return _parseSentiment([item]);
  }

  double _parseConfidenceFromBatch(dynamic item) {
    return _parseConfidence([item]);
  }

  void _updateSummary() {
    _sentimentSummary = {'pozitif': 0, 'negatif': 0, 'nötr': 0};
    for (final r in _results) {
      final s = r['sentiment'] as String;
      if (s == 'pozitif') _sentimentSummary['pozitif'] = (_sentimentSummary['pozitif'] ?? 0) + 1;
      else if (s == 'negatif') _sentimentSummary['negatif'] = (_sentimentSummary['negatif'] ?? 0) + 1;
      else _sentimentSummary['nötr'] = (_sentimentSummary['nötr'] ?? 0) + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yorum Analizi'),
        backgroundColor: AppTheme.darkBg,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(icon: Icon(Icons.edit_note_rounded), text: 'Tek Yorum'),
            Tab(icon: Icon(Icons.list_alt_rounded), text: 'Toplu Analiz'),
            Tab(icon: Icon(Icons.pie_chart_rounded), text: 'Özet'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSingleAnalysisTab(),
          _buildBatchAnalysisTab(),
          _buildSummaryTab(),
        ],
      ),
    );
  }

  // ─── TAB 1: Tek Yorum Analizi ───
  Widget _buildSingleAnalysisTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Bilgi kartı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor.withOpacity(0.15), Colors.transparent],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.psychology_rounded, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Hugging Face Türkçe BERT modeli ile duygu analizi',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Yorum girişi
          TextField(
            controller: _yorumController,
            maxLines: 4,
            style: const TextStyle(fontFamily: 'Inter', color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Müşteri yorumunu buraya yazın...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () => _yorumController.clear(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Analiz butonu
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : _analyzeSingleReview,
              icon: _isAnalyzing
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(_isAnalyzing ? 'Analiz ediliyor...' : 'AI ile Analiz Et'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Sonuçlar
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.comment_rounded, size: 48, color: Colors.white.withOpacity(0.15)),
                        const SizedBox(height: 12),
                        Text(
                          'Henüz analiz yapılmadı',
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontFamily: 'Inter'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) => _buildResultCard(_results[index]),
                  ),
          ),
        ],
      ),
    );
  }

  // ─── TAB 2: Toplu Analiz ───
  Widget _buildBatchAnalysisTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📊 Toplu Yorum Analizi',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_sampleReviews.length} örnek yorum hazır. Tümünü AI ile analiz edin.',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withOpacity(0.6)),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : _analyzeBatchReviews,
                    icon: _isAnalyzing
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.play_arrow_rounded),
                    label: Text(_isAnalyzing ? 'Analiz ediliyor...' : 'Tümünü Analiz Et'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _results.isEmpty
                ? ListView.builder(
                    itemCount: _sampleReviews.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.darkCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.darkBorder),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppTheme.darkBorder,
                              child: Text('${index + 1}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _sampleReviews[index],
                                style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) => _buildResultCard(_results[index]),
                  ),
          ),
        ],
      ),
    );
  }

  // ─── TAB 3: Özet ───
  Widget _buildSummaryTab() {
    final total = _results.length;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Duygu dağılımı
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Column(
              children: [
                const Text(
                  'Duygu Dağılımı',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 24),
                if (total == 0)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Henüz analiz yapılmadı',
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontFamily: 'Inter'),
                    ),
                  )
                else ...[
                  _buildSentimentBar('Pozitif', _sentimentSummary['pozitif']!, total, AppTheme.successColor),
                  const SizedBox(height: 16),
                  _buildSentimentBar('Negatif', _sentimentSummary['negatif']!, total, AppTheme.accentColor),
                  const SizedBox(height: 16),
                  _buildSentimentBar('Nötr', _sentimentSummary['nötr']!, total, Colors.grey),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // İstatistikler
          Row(
            children: [
              Expanded(child: _buildMiniStat('Toplam', '$total', Icons.comment_rounded, AppTheme.primaryColor)),
              const SizedBox(width: 12),
              Expanded(child: _buildMiniStat('Pozitif', '${_sentimentSummary['pozitif']}', Icons.thumb_up_rounded, AppTheme.successColor)),
              const SizedBox(width: 12),
              Expanded(child: _buildMiniStat('Negatif', '${_sentimentSummary['negatif']}', Icons.thumb_down_rounded, AppTheme.accentColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentBar(String label, int count, int total, Color color) {
    final ratio = total > 0 ? count / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white70)),
            Text('${(ratio * 100).toStringAsFixed(0)}%', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: AppTheme.darkBorder,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    final sentiment = result['sentiment'] as String;
    final confidence = result['confidence'] as double;
    final text = result['text'] as String;

    Color sentimentColor;
    IconData sentimentIcon;
    String sentimentLabel;

    switch (sentiment) {
      case 'pozitif':
        sentimentColor = AppTheme.successColor;
        sentimentIcon = Icons.sentiment_very_satisfied_rounded;
        sentimentLabel = 'Pozitif';
        break;
      case 'negatif':
        sentimentColor = AppTheme.accentColor;
        sentimentIcon = Icons.sentiment_very_dissatisfied_rounded;
        sentimentLabel = 'Negatif';
        break;
      default:
        sentimentColor = Colors.grey;
        sentimentIcon = Icons.sentiment_neutral_rounded;
        sentimentLabel = 'Nötr';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sentimentColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(sentimentIcon, color: sentimentColor, size: 20),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: sentimentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    sentimentLabel,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: sentimentColor),
                  ),
                ),
                const Spacer(),
                if (confidence > 0)
                  Text(
                    '%${(confidence * 100).toStringAsFixed(0)} güven',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white.withOpacity(0.4)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
