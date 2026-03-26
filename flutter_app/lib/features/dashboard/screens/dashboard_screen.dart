import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../yorum_analizi/screens/yorum_analizi_screen.dart';
import '../../rakip_analizi/screens/rakip_analizi_screen.dart';
import '../../fiyat_analizi/screens/fiyat_analizi_screen.dart';
import '../../kampanya/screens/kampanya_onerileri_screen.dart';
import '../providers/dashboard_provider.dart';

/// Dashboard Ekranı — İşletme türüne göre kişiselleştirilmiş
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<DashboardProvider>().loadDashboardData(
        businessType: auth.businessType,
        location: auth.businessLocation,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _buildDashboardHome();
      case 1: return const YorumAnaliziScreen();
      case 2: return const RakipAnaliziScreen();
      case 3: return const FiyatAnaliziScreen();
      case 4: return const KampanyaOnerileriScreen();
      default: return _buildDashboardHome();
    }
  }

  Widget _buildDashboardHome() {
    return Consumer2<DashboardProvider, AuthProvider>(
      builder: (context, dashboard, auth, _) {
        // Analiz yükleniyor ekranı
        if (dashboard.isLoading) {
          return _buildAnalysisLoading(dashboard.analysisStatus, auth);
        }
        return CustomScrollView(
          slivers: [
            _buildAppBar(),
            _buildWelcome(auth, dashboard),
            // Analiz Grafikleri (en üstte)
            _buildChartsSection(dashboard),
            _buildStatGrid(dashboard),
            // AI Insights
            if (dashboard.recentInsights.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(children: [
                    const Icon(Icons.auto_awesome, color: AppTheme.secondaryColor, size: 18),
                    const SizedBox(width: 8),
                    Text('AI Öngörüleri', style: Theme.of(context).textTheme.titleLarge),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildInsightCard(dashboard.recentInsights[i]),
                    ),
                    childCount: dashboard.recentInsights.length,
                  ),
                ),
              ),
            ],
            _buildQuickActions(),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }

  /// Analiz yükleniyor animasyonu
  Widget _buildAnalysisLoading(String status, AuthProvider auth) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1a1d42), AppTheme.darkBg],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animasyonlu ikon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (value * 0.2),
                child: Opacity(opacity: 0.5 + (value * 0.5), child: child),
              );
            },
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.4), blurRadius: 30)],
              ),
              child: const Icon(Icons.analytics_rounded, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            auth.businessName.isEmpty ? 'İşletmeniz' : auth.businessName,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(status, style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: AppTheme.darkBg,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('AnalizAI', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w800, fontSize: 20)),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF1a1d42), AppTheme.darkBg], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
        ),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        Consumer<AuthProvider>(builder: (context, auth, _) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor,
              child: Text(auth.displayName.isNotEmpty ? auth.displayName[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWelcome(AuthProvider auth, DashboardProvider dashboard) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hoşgeldin, ${auth.displayName.split(' ').first} 👋',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.store_rounded, size: 14, color: Colors.white.withOpacity(0.5)),
              const SizedBox(width: 4),
              Text(
                auth.businessName.isNotEmpty ? '${auth.businessName} • ${auth.businessLocation}' : 'İşletmenizin güncel durumu',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withOpacity(0.5)),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid(DashboardProvider dashboard) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.5,
        ),
        delegate: SliverChildListDelegate([
          _buildStatCard('Toplam Yorum', '${dashboard.totalReviews}', Icons.comment_rounded, AppTheme.primaryColor),
          _buildStatCard('Rakipler', '${dashboard.competitorCount}', Icons.storefront_rounded, AppTheme.secondaryColor),
          _buildStatCard('Memnuniyet', '%${dashboard.sentimentScore.toStringAsFixed(0)}', Icons.sentiment_satisfied_rounded, AppTheme.successColor),
          _buildStatCard('Kampanya Fikri', '${dashboard.campaignSuggestions}', Icons.campaign_rounded, AppTheme.warningColor),
        ]),
      ),
    );
  }

  Widget _buildInsightCard(Map<String, dynamic> insight) {
    Color borderColor;
    switch (insight['type']) {
      case 'warning': borderColor = AppTheme.warningColor; break;
      case 'success': borderColor = AppTheme.successColor; break;
      case 'tip': borderColor = AppTheme.secondaryColor; break;
      default: borderColor = AppTheme.primaryColor;
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(insight['icon'] as String, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insight['title'] as String, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 4),
                Text(insight['text'] as String, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(DashboardProvider dashboard) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.bar_chart_rounded, color: AppTheme.primaryColor, size: 18),
              const SizedBox(width: 8),
              Text('Analiz Grafikleri', style: Theme.of(context).textTheme.titleLarge),
            ]),
            const SizedBox(height: 16),
            // 1. Müşteri Memnuniyet Trendi — Line Chart (en üstte)
            _buildLineChart(dashboard),
            const SizedBox(height: 16),
            // 2. Yorum Dağılımı + Aylık Performans — aynı satırda, kare
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _buildSentimentDistributionChart(dashboard)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMonthlyTrendChart(dashboard)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Müşteri Memnuniyet Trendi — Line Chart with CustomPaint
  Widget _buildLineChart(DashboardProvider dashboard) {
    final random = Random(dashboard.totalReviews + 7);
    final dataPoints = List.generate(12, (i) => 50.0 + random.nextInt(40) + (i * 1.5));
    final labels = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    final currentMonth = 3; // Mart

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryColor.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.show_chart_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Müşteri Memnuniyet Trendi', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppTheme.successColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.trending_up_rounded, size: 12, color: AppTheme.successColor),
                const SizedBox(width: 3),
                Text('+${random.nextInt(6) + 4}%', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.successColor)),
              ]),
            ),
          ]),
          const SizedBox(height: 6),
          Text('12 aylık memnuniyet oranı (%)', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white.withOpacity(0.4))),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, animValue, _) {
              return SizedBox(
                height: 180,
                child: CustomPaint(
                  size: const Size(double.infinity, 180),
                  painter: _LineChartPainter(
                    dataPoints: dataPoints,
                    animationValue: animValue,
                    lineColor: AppTheme.primaryColor,
                    fillColor: AppTheme.primaryColor.withOpacity(0.08),
                    dotColor: AppTheme.secondaryColor,
                    currentIndex: currentMonth - 1,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          // Month labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(12, (i) {
              final isCurrent = i == currentMonth - 1;
              return Text(
                labels[i],
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 8,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                  color: isCurrent ? AppTheme.secondaryColor : Colors.white.withOpacity(0.3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Haftalık Duygu Analizi Bar Chart
  Widget _buildWeeklySentimentChart(DashboardProvider dashboard) {
    final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    final random = Random(dashboard.totalReviews);
    final posData = List.generate(7, (_) => 40 + random.nextInt(50));
    final negData = List.generate(7, (_) => 10 + random.nextInt(30));
    final maxVal = [...posData, ...negData].reduce((a, b) => a > b ? a : b).toDouble();

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
          Row(children: [
            const Text('Haftalık Duygu Analizi', style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppTheme.successColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
              child: const Text('Son 7 Gün', style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppTheme.successColor, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            _chartLegend(AppTheme.successColor, 'Pozitif'),
            const SizedBox(width: 16),
            _chartLegend(AppTheme.accentColor, 'Negatif'),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final posH = (posData[i] / maxVal) * 120;
                final negH = (negData[i] / maxVal) * 120;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _animatedBar(posH, AppTheme.successColor, i * 80),
                            const SizedBox(width: 2),
                            _animatedBar(negH, AppTheme.accentColor, i * 80 + 40),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(days[i], style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: Colors.white.withOpacity(0.4))),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _animatedBar(double height, Color color, int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: height),
      duration: Duration(milliseconds: 600 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Container(
          width: 10,
          height: value,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        );
      },
    );
  }

  Widget _chartLegend(Color color, String label) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white.withOpacity(0.5))),
    ]);
  }

  /// Yorum Dağılımı Horizontal Bars
  Widget _buildSentimentDistributionChart(DashboardProvider dashboard) {
    final total = dashboard.totalReviews > 0 ? dashboard.totalReviews : 100;
    final posPercent = dashboard.sentimentScore / 100;
    final negPercent = (100 - dashboard.sentimentScore - 12) / 100;
    final neutralPercent = 1.0 - posPercent - negPercent;

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
          const Text('Yorum Dağılımı', style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 16),
          // Stacked bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 28,
              child: Row(children: [
                Expanded(flex: (posPercent * 100).round(), child: Container(color: AppTheme.successColor)),
                Expanded(flex: (neutralPercent * 100).round().clamp(1, 100), child: Container(color: Colors.grey.shade600)),
                Expanded(flex: (negPercent * 100).round().clamp(1, 100), child: Container(color: AppTheme.accentColor)),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          _distributionRow('😊 Pozitif', (posPercent * total).round(), posPercent, AppTheme.successColor),
          const SizedBox(height: 10),
          _distributionRow('😐 Nötr', (neutralPercent * total).round(), neutralPercent, Colors.grey),
          const SizedBox(height: 10),
          _distributionRow('😞 Negatif', (negPercent * total).round(), negPercent, AppTheme.accentColor),
        ],
      ),
    );
  }

  Widget _distributionRow(String label, int count, double ratio, Color color) {
    return Row(children: [
      Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withOpacity(0.7))),
      const Spacer(),
      Text('$count yorum', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withOpacity(0.4))),
      const SizedBox(width: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
        child: Text('%${(ratio * 100).toStringAsFixed(0)}', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ),
    ]);
  }

  /// Aylık Performans Trend
  Widget _buildMonthlyTrendChart(DashboardProvider dashboard) {
    final months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz'];
    final random = Random(dashboard.sentimentScore.round());
    final trendData = List.generate(6, (i) => 55.0 + random.nextInt(35) + i * 2.0);
    final maxVal = trendData.reduce((a, b) => a > b ? a : b);

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
          Row(children: [
            const Text('Aylık Performans', style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            const Spacer(),
            Icon(Icons.trending_up_rounded, size: 16, color: AppTheme.successColor),
            const SizedBox(width: 4),
            Text('+${random.nextInt(8) + 3}%', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.successColor)),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(6, (i) {
                final h = (trendData[i] / maxVal) * 100;
                final isLast = i == 5;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('%${trendData[i].toStringAsFixed(0)}', style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: isLast ? AppTheme.secondaryColor : Colors.white.withOpacity(0.3))),
                        const SizedBox(height: 4),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: h),
                          duration: Duration(milliseconds: 500 + i * 100),
                          curve: Curves.easeOutCubic,
                          builder: (_, v, __) => Container(
                            width: double.infinity,
                            height: v,
                            decoration: BoxDecoration(
                              gradient: isLast
                                  ? const LinearGradient(colors: [AppTheme.secondaryColor, AppTheme.primaryColor], begin: Alignment.bottomCenter, end: Alignment.topCenter)
                                  : LinearGradient(colors: [AppTheme.primaryColor.withOpacity(0.4), AppTheme.primaryColor.withOpacity(0.7)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(months[i], style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: Colors.white.withOpacity(0.4))),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hızlı Erişim', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _buildQuickActionCard('Yorum Analizi', 'Müşteri yorumlarını AI ile analiz et', Icons.psychology_rounded, AppTheme.primaryGradient, () => setState(() => _currentIndex = 1)),
            const SizedBox(height: 10),
            _buildQuickActionCard('Rakip Tarama', 'Çevrendeki rakipleri otomatik bul', Icons.radar_rounded, AppTheme.accentGradient, () => setState(() => _currentIndex = 2)),
            const SizedBox(height: 10),
            _buildQuickActionCard('Fiyat Analizi', 'Menü fotoğrafından fiyatları oku', Icons.document_scanner_rounded, const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)]), () => setState(() => _currentIndex = 3)),
            const SizedBox(height: 10),
            _buildQuickActionCard('Kampanya Önerileri', 'AI destekli kampanya fikirleri al', Icons.auto_awesome_rounded, const LinearGradient(colors: [Color(0xFF4ECDC4), Color(0xFF44B09E)]), () => setState(() => _currentIndex = 4)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.darkBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Icon(icon, color: color, size: 24),
        const Spacer(),
        Text(value, style: TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(title, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.6))),
      ]),
    );
  }

  Widget _buildQuickActionCard(String title, String subtitle, IconData icon, LinearGradient gradient, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.darkBorder)),
          child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.white, size: 24)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withOpacity(0.5))),
            ])),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.3), size: 16),
          ]),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(color: AppTheme.darkSurface, border: Border(top: BorderSide(color: AppTheme.darkBorder, width: 1))),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Panel'),
          BottomNavigationBarItem(icon: Icon(Icons.comment_rounded), label: 'Yorumlar'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_rounded), label: 'Rakipler'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money_rounded), label: 'Fiyat'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign_rounded), label: 'Kampanya'),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppTheme.darkSurface,
      child: ListView(padding: EdgeInsets.zero, children: [
        Consumer<AuthProvider>(builder: (context, auth, _) {
          return DrawerHeader(
            decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
              CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: Text(auth.displayName.isNotEmpty ? auth.displayName[0] : 'U', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white))),
              const SizedBox(height: 12),
              Text(auth.displayName, style: const TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              Text(auth.businessName.isNotEmpty ? auth.businessName : auth.email,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white70)),
            ]),
          );
        }),
        _buildDrawerItem(Icons.dashboard_rounded, 'Panel', 0),
        _buildDrawerItem(Icons.comment_rounded, 'Yorum Analizi', 1),
        _buildDrawerItem(Icons.storefront_rounded, 'Rakip Analizi', 2),
        _buildDrawerItem(Icons.attach_money_rounded, 'Fiyat Analizi', 3),
        _buildDrawerItem(Icons.campaign_rounded, 'Kampanyalar', 4),
        const Divider(color: AppTheme.darkBorder),
        ListTile(
          leading: const Icon(Icons.logout_rounded, color: AppTheme.accentColor),
          title: const Text('Çıkış Yap', style: TextStyle(color: AppTheme.accentColor)),
          onTap: () async {
            Navigator.pop(context);
            await context.read<AuthProvider>().signOut();
            if (mounted) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
          },
        ),
      ]),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    final isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.white54),
      title: Text(title, style: TextStyle(fontFamily: 'Inter', color: isSelected ? AppTheme.primaryColor : Colors.white, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
      selected: isSelected,
      selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () { setState(() => _currentIndex = index); Navigator.pop(context); },
    );
  }
}

/// Custom Line Chart Painter — Smooth Bezier curves
class _LineChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final double animationValue;
  final Color lineColor;
  final Color fillColor;
  final Color dotColor;
  final int currentIndex;

  _LineChartPainter({
    required this.dataPoints,
    required this.animationValue,
    required this.lineColor,
    required this.fillColor,
    required this.dotColor,
    required this.currentIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final minVal = dataPoints.reduce((a, b) => a < b ? a : b) - 5;
    final maxVal = dataPoints.reduce((a, b) => a > b ? a : b) + 5;
    final range = maxVal - minVal;

    final w = size.width;
    final h = size.height;
    final stepX = w / (dataPoints.length - 1);

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0x0DFFFFFF)
      ..strokeWidth = 1;
    for (int i = 0; i < 4; i++) {
      final y = h * i / 3;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Calculate points
    final points = <Offset>[];
    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final normalizedY = (dataPoints[i] - minVal) / range;
      final y = h - (normalizedY * h * animationValue);
      points.add(Offset(x, y));
    }

    // Draw fill path
    final fillPath = Path();
    fillPath.moveTo(0, h);
    fillPath.lineTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final cp1x = points[i].dx + stepX * 0.4;
      final cp1y = points[i].dy;
      final cp2x = points[i + 1].dx - stepX * 0.4;
      final cp2y = points[i + 1].dy;
      fillPath.cubicTo(cp1x, cp1y, cp2x, cp2y, points[i + 1].dx, points[i + 1].dy);
    }
    fillPath.lineTo(w, h);
    fillPath.close();

    final fillGradient = Paint()
      ..shader = LinearGradient(
        colors: [fillColor, fillColor.withOpacity(0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(fillPath, fillGradient);

    // Draw line
    final linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final cp1x = points[i].dx + stepX * 0.4;
      final cp1y = points[i].dy;
      final cp2x = points[i + 1].dx - stepX * 0.4;
      final cp2y = points[i + 1].dy;
      linePath.cubicTo(cp1x, cp1y, cp2x, cp2y, points[i + 1].dx, points[i + 1].dy);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // Draw dots
    for (int i = 0; i < points.length; i++) {
      final isCurrent = i == currentIndex;
      final dotRadius = isCurrent ? 5.0 : 2.5;
      final color = isCurrent ? dotColor : lineColor.withOpacity(0.6);

      if (isCurrent) {
        // Glow effect
        canvas.drawCircle(points[i], 10, Paint()..color = dotColor.withOpacity(0.15));
        canvas.drawCircle(points[i], 7, Paint()..color = dotColor.withOpacity(0.2));
      }
      canvas.drawCircle(points[i], dotRadius, Paint()..color = color);
      if (isCurrent) {
        canvas.drawCircle(points[i], dotRadius - 1.5, Paint()..color = const Color(0xFFFFFFFF));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
