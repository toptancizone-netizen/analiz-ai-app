import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/constants/api_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/dashboard/providers/dashboard_provider.dart';

/// AnalizAI — Yerel İşletmeler İçin AI Destekli Analiz Platformu
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase başlat (hata durumunda uygulamayı yine de çalıştır)
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: ApiConstants.firebaseApiKey,
        authDomain: 'analizai.firebaseapp.com',
        projectId: ApiConstants.firebaseProjectId,
        appId: ApiConstants.firebaseAppId,
        messagingSenderId: ApiConstants.firebaseMessagingSenderId,
        storageBucket: ApiConstants.firebaseStorageBucket,
      ),
    );
  } catch (e) {
    // Firebase zaten başlatıldıysa veya web SDK eksikse devam et
    debugPrint('Firebase init warning: $e');
  }

  runApp(const AnalizAIApp());
}

class AnalizAIApp extends StatelessWidget {
  const AnalizAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        title: 'AnalizAI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const LoginScreen(),
      ),
    );
  }
}
