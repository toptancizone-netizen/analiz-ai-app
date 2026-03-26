import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase Authentication Provider
/// Google Sign-In ile giriş/çıkış yönetimi + Demo mod
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isDemoMode = false;

  // İşletme bilgileri (demo mod)
  String _businessName = '';
  String _businessType = '';
  String _businessLocation = '';
  String _ownerName = '';

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null || _isDemoMode;
  bool get isDemoMode => _isDemoMode;
  String? get error => _error;
  String get displayName => _isDemoMode ? _ownerName : (_user?.displayName ?? 'Kullanıcı');
  String get email => _isDemoMode ? '$_businessType@analizai.demo' : (_user?.email ?? '');
  String? get photoUrl => _user?.photoURL;

  // İşletme bilgileri
  String get businessName => _businessName;
  String get businessType => _businessType;
  String get businessLocation => _businessLocation;
  String get ownerName => _ownerName;

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

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final auth = FirebaseAuth.instance;
      final UserCredential userCredential = await auth.signInWithCredential(credential);
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
      _error = 'Google giriş başarısız. Demo mod ile devam edebilirsiniz.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Demo mod ile giriş
  Future<bool> signInAsDemo({
    required String ownerName,
    required String businessName,
    required String businessType,
    required String businessLocation,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    _isDemoMode = true;
    _ownerName = ownerName.isEmpty ? 'Demo Kullanıcı' : ownerName;
    _businessName = businessName.isEmpty ? 'Demo İşletme' : businessName;
    _businessType = businessType;
    _businessLocation = businessLocation.isEmpty ? 'İstanbul' : businessLocation;

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
      _ownerName = '';
      _businessName = '';
      _businessType = '';
      _businessLocation = '';
    } catch (e) {
      _error = 'Çıkış yapılırken bir hata oluştu';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'Bu e-posta farklı bir giriş yöntemiyle kayıtlı.';
      case 'invalid-credential':
        return 'Geçersiz kimlik bilgisi.';
      case 'operation-not-allowed':
        return 'Bu giriş yöntemi aktif değil.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'network-request-failed':
        return 'İnternet bağlantısı yok.';
      default:
        return 'Bir hata oluştu ($code).';
    }
  }
}
