import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/screens/dashboard_screen.dart';

/// Giriş Ekranı — Firebase Google Sign-In + Demo Mod
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn) _navigateToDashboard();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();
    if (success && mounted) {
      _navigateToDashboard();
    } else if (auth.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error!),
          backgroundColor: AppTheme.accentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'Demo Giriş',
            textColor: Colors.white,
            onPressed: _showDemoLoginDialog,
          ),
        ),
      );
    }
  }

  void _showDemoLoginDialog() {
    final ownerNameCtrl = TextEditingController();
    final businessNameCtrl = TextEditingController();
    final locationCtrl = TextEditingController(text: 'İstanbul');
    final phoneCtrl = TextEditingController();
    String selectedType = 'restoran';
    int employeeCount = 3;
    int yearsInBusiness = 1;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: AppTheme.darkCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.rocket_launch, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Hadi Başlayalım!',
                  style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'İşletmenizi tanıyalım, size özel bir analiz hazırlayalım.',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontFamily: 'Inter', fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  // Ad Soyad
                  _buildDialogField(
                    controller: ownerNameCtrl,
                    label: 'Adınız Soyadınız',
                    hint: 'Örn: Ahmet Yılmaz',
                    icon: Icons.person_rounded,
                  ),
                  const SizedBox(height: 14),
                  // Telefon
                  _buildDialogField(
                    controller: phoneCtrl,
                    label: 'Telefon',
                    hint: 'Örn: 0532 123 4567',
                    icon: Icons.phone_rounded,
                  ),
                  const SizedBox(height: 14),
                  // İşletme Adı
                  _buildDialogField(
                    controller: businessNameCtrl,
                    label: 'İşletme Adı',
                    hint: 'Örn: Lezzet Dünyası',
                    icon: Icons.store_rounded,
                  ),
                  const SizedBox(height: 14),
                  // İşletme Türü
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    dropdownColor: AppTheme.darkCard,
                    style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                    decoration: _inputDecoration('İşletme Türü', Icons.category_rounded),
                    items: const [
                      DropdownMenuItem(value: 'restoran', child: Text('🍽️  Restoran / Lokanta')),
                      DropdownMenuItem(value: 'kafe', child: Text('☕  Kafe / Kahveci')),
                      DropdownMenuItem(value: 'market', child: Text('🛒  Market / Bakkal')),
                      DropdownMenuItem(value: 'kuafor', child: Text('💇  Kuaför / Güzellik')),
                      DropdownMenuItem(value: 'eczane', child: Text('💊  Eczane')),
                      DropdownMenuItem(value: 'diger', child: Text('🏪  Diğer')),
                    ],
                    onChanged: (val) => setDialogState(() => selectedType = val ?? 'restoran'),
                  ),
                  const SizedBox(height: 14),
                  // Konum
                  _buildDialogField(
                    controller: locationCtrl,
                    label: 'İşletme Konumu',
                    hint: 'Örn: Kadıköy, İstanbul',
                    icon: Icons.location_on_rounded,
                  ),
                  const SizedBox(height: 18),
                  // Çalışan Sayısı
                  Text('Çalışan Sayısı: $employeeCount kişi', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withOpacity(0.7))),
                  Slider(
                    value: employeeCount.toDouble(),
                    min: 1, max: 50, divisions: 49,
                    activeColor: AppTheme.primaryColor,
                    inactiveColor: AppTheme.darkBorder,
                    label: '$employeeCount',
                    onChanged: (v) => setDialogState(() => employeeCount = v.round()),
                  ),
                  const SizedBox(height: 8),
                  // Kaç Yıldır Açık
                  Text('Kaç yıldır açık: $yearsInBusiness yıl', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withOpacity(0.7))),
                  Slider(
                    value: yearsInBusiness.toDouble(),
                    min: 0, max: 30, divisions: 30,
                    activeColor: AppTheme.secondaryColor,
                    inactiveColor: AppTheme.darkBorder,
                    label: '$yearsInBusiness',
                    onChanged: (v) => setDialogState(() => yearsInBusiness = v.round()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('İptal', style: TextStyle(color: Colors.white.withOpacity(0.5))),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final auth = context.read<AuthProvider>();
                  final success = await auth.signInAsDemo(
                    ownerName: ownerNameCtrl.text,
                    businessName: businessNameCtrl.text,
                    businessType: selectedType,
                    businessLocation: locationCtrl.text,
                    phone: phoneCtrl.text,
                    employeeCount: employeeCount,
                    yearsInBusiness: yearsInBusiness,
                  );
                  if (success && mounted) _navigateToDashboard();
                },
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Analiz Et', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
      decoration: _inputDecoration(label, icon).copyWith(hintText: hint, hintStyle: TextStyle(color: Colors.white.withOpacity(0.25))),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontFamily: 'Inter', fontSize: 13),
      prefixIcon: Icon(icon, color: AppTheme.secondaryColor, size: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.darkBg, Color(0xFF13163F), AppTheme.darkBg],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    _buildLogo(),
                    const SizedBox(height: 16),
                    _buildTitle(),
                    const SizedBox(height: 8),
                    _buildSubtitle(),
                    const Spacer(flex: 2),
                    _buildFeatureChips(),
                    const SizedBox(height: 48),
                    _buildGoogleSignInButton(),
                    const SizedBox(height: 12),
                    _buildDemoButton(),
                    const SizedBox(height: 16),
                    _buildTermsText(),
                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100, height: 100,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: const Icon(Icons.analytics_rounded, size: 50, color: Colors.white),
    );
  }

  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => AppTheme.accentGradient.createShader(bounds),
      child: const Text('AnalizAI', style: TextStyle(fontFamily: 'Inter', fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
    );
  }

  Widget _buildSubtitle() {
    return Text('İşletmenizi AI ile güçlendirin', style: TextStyle(fontFamily: 'Inter', fontSize: 16, color: Colors.white.withOpacity(0.6)));
  }

  Widget _buildFeatureChips() {
    final features = [
      {'icon': Icons.comment_rounded, 'text': 'Yorum Analizi'},
      {'icon': Icons.storefront_rounded, 'text': 'Rakip Analizi'},
      {'icon': Icons.attach_money_rounded, 'text': 'Fiyat Önerisi'},
      {'icon': Icons.campaign_rounded, 'text': 'Kampanya Önerisi'},
    ];
    return Wrap(
      alignment: WrapAlignment.center, spacing: 8, runSpacing: 8,
      children: features.map((f) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.darkCard.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(f['icon'] as IconData, size: 16, color: AppTheme.secondaryColor),
          const SizedBox(width: 6),
          Text(f['text'] as String, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70)),
        ]),
      )).toList(),
    );
  }

  Widget _buildGoogleSignInButton() {
    return Consumer<AuthProvider>(builder: (context, auth, _) {
      return SizedBox(
        width: double.infinity, height: 56,
        child: ElevatedButton(
          onPressed: auth.isLoading ? null : _handleGoogleSignIn,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black87, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: auth.isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primaryColor))
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.g_mobiledata_rounded, color: Color(0xFF4285F4), size: 28),
                  const SizedBox(width: 12),
                  const Text('Google ile Giriş Yap', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600)),
                ]),
        ),
      );
    });
  }

  Widget _buildDemoButton() {
    return Consumer<AuthProvider>(builder: (context, auth, _) {
      return SizedBox(
        width: double.infinity, height: 48,
        child: OutlinedButton.icon(
          onPressed: auth.isLoading ? null : _showDemoLoginDialog,
          icon: const Icon(Icons.rocket_launch_rounded, size: 18),
          label: const Text('Demo ile Keşfet', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.secondaryColor,
            side: BorderSide(color: AppTheme.secondaryColor.withOpacity(0.4)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
    });
  }

  Widget _buildTermsText() {
    return Text('Giriş yaparak Kullanım Koşullarını kabul edersiniz.', textAlign: TextAlign.center,
      style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white.withOpacity(0.35)));
  }
}
