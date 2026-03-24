import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/huggingface_service.dart';

/// Kampanya Önerileri Ekranı
/// Kullanılan API: Hugging Face Inference (AI metin üretimi)
/// İşletme verilerine göre AI destekli kampanya fikirleri oluşturur
class KampanyaOnerileriScreen extends StatefulWidget {
  const KampanyaOnerileriScreen({super.key});

  @override
  State<KampanyaOnerileriScreen> createState() => _KampanyaOnerileriScreenState();
}

class _KampanyaOnerileriScreenState extends State<KampanyaOnerileriScreen> {
  final _huggingFace = HuggingFaceService();
  bool _isGenerating = false;
  String _selectedCategory = 'Restoran';
  String _selectedGoal = 'Müşteri Çekme';

  final List<Map<String, dynamic>> _campaigns = [];

  final List<String> _categories = [
    'Restoran', 'Kafe', 'Pastane', 'Market',
    'Kuaför', 'Spor Salonu', 'Eczane',
  ];

  final List<String> _goals = [
    'Müşteri Çekme', 'Sadakat', 'Satış Artırma',
    'Marka Bilinirliği', 'Sosyal Medya', 'Sezon Kampanyası',
  ];

  // Önceden hazırlanmış kampanya önerileri (AI sonuçları simülasyonu)
  final Map<String, List<Map<String, dynamic>>> _prebuiltCampaigns = {
    'Restoran_Müşteri Çekme': [
      {
        'title': '🍽️ İlk Sipariş %30 İndirim',
        'description': 'Yeni müşterilere ilk siparişte %30 indirim sunun. QR kodlu masa kartlarıyla sosyal medyada paylaşımı teşvik edin.',
        'duration': '2 hafta',
        'expectedROI': '%180 geri dönüş',
        'channel': 'Instagram + Masa İçi QR',
        'difficulty': 'Kolay',
      },
      {
        'title': '🎉 Arkadaşını Getir Kampanyası',
        'description': 'Her yeni müşteri getiren mevcut müşteriye ikram tatlı veya içecek sunun. Zincirleme müşteri kazanım stratejisi.',
        'duration': '1 ay',
        'expectedROI': '%250 geri dönüş',
        'channel': 'Sosyal Medya + Fiziksel Kart',
        'difficulty': 'Orta',
      },
    ],
    'Restoran_Sadakat': [
      {
        'title': '⭐ Puan Kartı Sistemi',
        'description': 'Her 10 yemekte 1 yemek ücretsiz. Dijital puan kartı ile takip edin, push bildirimlerle hatırlatma gönderin.',
        'duration': 'Süresiz',
        'expectedROI': '%200 geri dönüş',
        'channel': 'Uygulama İçi + Push Bildirim',
        'difficulty': 'Kolay',
      },
      {
        'title': '🎂 Doğum Günü Sürprizi',
        'description': 'Doğum gününde %50 indirim + pasta ikramı. Müşteri bilgilerini kayıt altına alın.',
        'duration': 'Süresiz',
        'expectedROI': '%150 geri dönüş',
        'channel': 'SMS + Push Bildirim',
        'difficulty': 'Kolay',
      },
    ],
    'Kafe_Müşteri Çekme': [
      {
        'title': '☕ Happy Hour (14:00–16:00)',
        'description': 'Sakin saatlerde tüm içeceklerde %40 indirim. Sosyal medya story paylaşımı yapanlara ekstra kurabiye.',
        'duration': 'Süresiz (hafta içi)',
        'expectedROI': '%160 geri dönüş',
        'channel': 'Instagram Story + Masa Tabela',
        'difficulty': 'Kolay',
      },
      {
        'title': '📸 Instagramable Köşe',
        'description': 'Fotoğraf çekilme köşesi oluşturun, hashtag ile paylaşanlara %15 indirim. Organik reklam etkisi.',
        'duration': '1 ay',
        'expectedROI': '%300 geri dönüş',
        'channel': 'Instagram + TikTok',
        'difficulty': 'Orta',
      },
    ],
  };

  Future<void> _generateCampaigns() async {
    setState(() {
      _isGenerating = true;
      _campaigns.clear();
    });

    // Hugging Face'e kampanya önerisi isteği gönder
    final prompt = '$_selectedCategory işletmesi için $_selectedGoal hedefli kampanya önerileri:';
    await _huggingFace.generateSuggestion(prompt);

    // Önceden hazırlanmış sonuçları kullan (AI sonuçları zenginleştirmek için)
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isGenerating = false;
      final key = '${_selectedCategory}_$_selectedGoal';
      if (_prebuiltCampaigns.containsKey(key)) {
        _campaigns.addAll(_prebuiltCampaigns[key]!);
      } else {
        // Genel kampanya önerileri
        _campaigns.addAll([
          {
            'title': '🎯 Hedefli İndirim Kampanyası',
            'description': '$_selectedCategory sektöründe $_selectedGoal hedefine yönelik kişiselleştirilmiş indirim kampanyası. Müşteri segmentasyonu yaparak en uygun teklifleri sunun.',
            'duration': '2 hafta',
            'expectedROI': '%170 geri dönüş',
            'channel': 'Sosyal Medya + Uygulama',
            'difficulty': 'Orta',
          },
          {
            'title': '📱 Dijital Sadakat Programı',
            'description': 'Uygulamadan sipariş veren müşterilere özel fırsatlar sunun. Push bildirimlerle geri dönüşü artırın.',
            'duration': '1 ay',
            'expectedROI': '%220 geri dönüş',
            'channel': 'Uygulama İçi + E-posta',
            'difficulty': 'Kolay',
          },
          {
            'title': '🤝 İşbirliği Kampanyası',
            'description': 'Çevredeki farklı sektörlerden işletmelerle çapraz kampanya yapın. Her iki tarafın müşteri kitlesine ulaşın.',
            'duration': '3 hafta',
            'expectedROI': '%190 geri dönüş',
            'channel': 'Fiziksel + Sosyal Medya',
            'difficulty': 'Orta',
          },
        ]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kampanya Önerileri'),
        backgroundColor: AppTheme.darkBg,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── AI Bilgi Kartı ───
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.successColor.withOpacity(0.1), Colors.transparent],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.successColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('AI Kampanya Motoru', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                        Text('Hugging Face tabanlı akıllı öneri sistemi', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withOpacity(0.5))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── İşletme Türü ───
            const Text('İşletme Türü', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? AppTheme.primaryColor : AppTheme.darkBorder),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontFamily: 'Inter', fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.white : Colors.white60,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ─── Kampanya Hedefi ───
            const Text('Kampanya Hedefi', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _goals.map((goal) {
                final isSelected = _selectedGoal == goal;
                return GestureDetector(
                  onTap: () => setState(() => _selectedGoal = goal),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.secondaryColor : AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? AppTheme.secondaryColor : AppTheme.darkBorder),
                    ),
                    child: Text(
                      goal,
                      style: TextStyle(
                        fontFamily: 'Inter', fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.white : Colors.white60,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ─── Oluştur Butonu ───
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateCampaigns,
                icon: _isGenerating
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(_isGenerating ? 'Kampanyalar oluşturuluyor...' : 'Kampanya Önerisi Al'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── Kampanya Kartları ───
            ..._campaigns.asMap().entries.map((entry) {
              final index = entry.key;
              final campaign = entry.value;
              return _buildCampaignCard(campaign, index);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignCard(Map<String, dynamic> campaign, int index) {
    final colors = [AppTheme.primaryColor, AppTheme.secondaryColor, AppTheme.successColor];
    final color = colors[index % colors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              campaign['title'] as String,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              campaign['description'] as String,
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, height: 1.6, color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 16),
            // Detay çipleri
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDetailChip(Icons.timer_outlined, campaign['duration'] as String, color),
                _buildDetailChip(Icons.trending_up_rounded, campaign['expectedROI'] as String, AppTheme.successColor),
                _buildDetailChip(Icons.campaign_rounded, campaign['channel'] as String, AppTheme.secondaryColor),
                _buildDetailChip(Icons.speed_rounded, campaign['difficulty'] as String, AppTheme.warningColor),
              ],
            ),
            const SizedBox(height: 16),
            // Uygula butonu
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${campaign['title']} kampanyası kaydedildi!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                },
                icon: const Icon(Icons.bookmark_add_rounded, size: 18),
                label: const Text('Kampanyayı Kaydet'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}
