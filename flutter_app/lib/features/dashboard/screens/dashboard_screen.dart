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

/// Dashboard Ekranı — Ana Sayfa
/// Bottom Navigation ile tüm analiz ekranlarına erişim
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
    // Dashboard verilerini yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardData();
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
      case 0:
        return _buildDashboardHome();
      case 1:
        return const YorumAnaliziScreen();
      case 2:
        return const RakipAnaliziScreen();
      case 3:
        return const FiyatAnaliziScreen();
      case 4:
        return const KampanyaOnerileriScreen();
      default:
        return _buildDashboardHome();
    }
  }

  // ─── Dashboard Ana Sayfa ───────────────────────────────────────────
  Widget _buildDashboardHome() {
    return Consumer<DashboardProvider>(
      builder: (context, dashboard, _) {
        return CustomScrollView(
          slivers: [
            // ─── App Bar ───
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: AppTheme.darkBg,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'AnalizAI',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1a1d42), AppTheme.darkBg],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppTheme.primaryColor,
                        backgroundImage: auth.photoUrl != null
                            ? NetworkImage(auth.photoUrl!)
                            : null,
                        child: auth.photoUrl == null
                            ? Text(
                                auth.displayName.isNotEmpty
                                    ? auth.displayName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ],
            ),
            // ─── Hoşgeldin Mesajı ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hoşgeldin, ${auth.displayName.split(' ').first} 👋',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'İşletmenizin güncel durumu',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            // ─── İstatistik Kartları ───
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                delegate: SliverChildListDelegate([
                  _buildStatCard(
                    'Toplam Yorum',
                    '${dashboard.totalReviews}',
                    Icons.comment_rounded,
                    AppTheme.primaryColor,
                  ),
                  _buildStatCard(
                    'Rakipler',
                    '${dashboard.competitorCount}',
                    Icons.storefront_rounded,
                    AppTheme.secondaryColor,
                  ),
                  _buildStatCard(
                    'Memnuniyet',
                    '%${dashboard.sentimentScore.toStringAsFixed(0)}',
                    Icons.sentiment_satisfied_rounded,
                    AppTheme.successColor,
                  ),
                  _buildStatCard(
                    'Kampanya Fikri',
                    '${dashboard.campaignSuggestions}',
                    Icons.campaign_rounded,
                    AppTheme.warningColor,
                  ),
                ]),
              ),
            ),
            // ─── Hızlı Erişim Kartları ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Hızlı Erişim',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildQuickActionCard(
                    'Yorum Analizi',
                    'Müşteri yorumlarını AI ile analiz et',
                    Icons.psychology_rounded,
                    AppTheme.primaryGradient,
                    () => setState(() => _currentIndex = 1),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionCard(
                    'Rakip Tarama',
                    'Çevrendeki rakipleri otomatik bul',
                    Icons.radar_rounded,
                    AppTheme.accentGradient,
                    () => setState(() => _currentIndex = 2),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionCard(
                    'Fiyat Analizi',
                    'Menü fotoğrafından fiyatları oku',
                    Icons.document_scanner_rounded,
                    const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                    ),
                    () => setState(() => _currentIndex = 3),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionCard(
                    'Kampanya Önerileri',
                    'AI destekli kampanya fikirleri al',
                    Icons.auto_awesome_rounded,
                    const LinearGradient(
                      colors: [Color(0xFF4ECDC4), Color(0xFF44B09E)],
                    ),
                    () => setState(() => _currentIndex = 4),
                  ),
                ]),
              ),
            ),
            // Alt boşluk
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }

  // ─── İstatistik Kartı ───
  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Hızlı Erişim Kartı ───
  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    LinearGradient gradient,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.3),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }



  // ─── Bottom Navigation ───
  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.darkSurface,
        border: Border(
          top: BorderSide(color: AppTheme.darkBorder, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Panel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.comment_rounded),
            label: 'Yorumlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_rounded),
            label: 'Rakipler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money_rounded),
            label: 'Fiyat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_rounded),
            label: 'Kampanya',
          ),
        ],
      ),
    );
  }

  // ─── Drawer Menü ───
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppTheme.darkSurface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer header
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      backgroundImage: auth.photoUrl != null
                          ? NetworkImage(auth.photoUrl!)
                          : null,
                      child: auth.photoUrl == null
                          ? Text(
                              auth.displayName.isNotEmpty
                                  ? auth.displayName[0]
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      auth.displayName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      auth.email,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Menü öğeleri
          _buildDrawerItem(Icons.dashboard_rounded, 'Panel', 0),
          _buildDrawerItem(Icons.comment_rounded, 'Yorum Analizi', 1),
          _buildDrawerItem(Icons.storefront_rounded, 'Rakip Analizi', 2),
          _buildDrawerItem(Icons.attach_money_rounded, 'Fiyat Analizi', 3),
          _buildDrawerItem(Icons.campaign_rounded, 'Kampanyalar', 4),
          const Divider(color: AppTheme.darkBorder),
          _buildDrawerItem(Icons.trending_up_rounded, 'Mahalle Trendleri', -1),
          _buildDrawerItem(Icons.credit_card_rounded, 'Abonelik', -1),
          _buildDrawerItem(Icons.settings_rounded, 'Ayarlar', -1),
          const Divider(color: AppTheme.darkBorder),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppTheme.accentColor),
            title: const Text(
              'Çıkış Yap',
              style: TextStyle(color: AppTheme.accentColor),
            ),
            onTap: () async {
              Navigator.pop(context); // drawer kapat
              await context.read<AuthProvider>().signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    final isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryColor : Colors.white54,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Inter',
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: index >= 0
          ? () {
              setState(() => _currentIndex = index);
              Navigator.pop(context);
            }
          : () {
              Navigator.pop(context);
              // Yakında gelecek ekranlar için
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title yakında aktif olacak'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
    );
  }
}
