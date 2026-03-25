import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase Authentication Provider
/// Google Sign-In ile giriş/çıkış yönetimi + Demo mod (web geliştirme için)
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isDemoMode = false;

  // Demo kullanıcı bilgileri
  String _demoName = '';
  String _demoEmail = '';

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null || _isDemoMode;
  bool get isDemoMode => _isDemoMode;
  String? get error => _error;
  String get displayName => _isDemoMode ? _demoName : (_user?.displayName ?? 'Kullanıcı');
  String get email => _isDemoMode ? _demoEmail : (_user?.email ?? '');
  String? get photoUrl => _user?.photoURL;

  AuthProvider() {
    _initAuth();
  }

  void _initAuth() {
    try {
      final auth = FirebaseAuth.instance;
      _user = auth.currentUser;

      auth.authStateChanges().listen((User? user) {
        _user = user;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Firebase Auth init error: $e');
    }
  }

  /// Google ile giriş yap
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        _isLoading = false;
        _error = 'Google giriş iptal edildi.';
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final auth = FirebaseAuth.instance;
      final UserCredential userCredential =
          await auth.signInWithCredential(credential);
      _user = userCredential.user;

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getFirebaseAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      // Web'de Google Sign-In çalışmıyor → Demo moda yönlendir
      _error = 'Google giriş başarısız. Demo mod ile devam edebilirsiniz.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Demo mod ile giriş (Firebase olmadan çalışır)
  Future<bool> signInAsDemo(String name, String businessType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Kısa bir gecikme (UX animasyonu için)
    await Future.delayed(const Duration(milliseconds: 800));

    _isDemoMode = true;
    _demoName = name.isEmpty ? 'Demo Kullanıcı' : name;
    _demoEmail = '$businessType@analizai.demo';

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Çıkış yap
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!_isDemoMode) {
        final auth = FirebaseAuth.instance;
        await auth.signOut();
      }
      _user = null;
      _isDemoMode = false;
      _demoName = '';
      _demoEmail = '';
    } catch (e) {
      _error = 'Çıkış yapılırken bir hata oluştu';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Hata mesajını temizle
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Firebase Auth hata mesajlarını Türkçe'ye çevir
  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'Bu e-posta adresi farklı bir giriş yöntemiyle kayıtlı.';
      case 'invalid-credential':
        return 'Geçersiz kimlik bilgisi.';
      case 'operation-not-allowed':
        return 'Bu giriş yöntemi aktif değil.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'user-not-found':
        return 'Kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Hatalı şifre.';
      case 'network-request-failed':
        return 'İnternet bağlantısı yok.';
      default:
        return 'Bir hata oluştu ($code).';
    }
  }
}
