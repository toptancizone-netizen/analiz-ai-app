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
