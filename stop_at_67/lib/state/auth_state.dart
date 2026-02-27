import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthState extends ChangeNotifier {
  final AuthService _authService;

  User? _user;
  String? _displayName;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<User?>? _authSub;

  AuthState(this._authService);

  User? get user => _user;
  String? get displayName => _displayName;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSignedIn => _user != null;
  String get userName => _displayName ?? _user?.displayName ?? 'Player';

  Future<void> initialize() async {
    _authSub = _authService.authStateChanges.listen(_onAuthChanged);
    // Load current user immediately if already signed in
    final current = _authService.currentUser;
    if (current != null) {
      await _onAuthChanged(current);
    }
  }

  Future<void> _onAuthChanged(User? user) async {
    _user = user;
    if (user != null) {
      _displayName = await _authService.getDisplayName(user);
    } else {
      _displayName = null;
    }
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _displayName = await _authService.getDisplayName(user);
      }
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _error = 'Google sign-in failed';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInAnonymous(String name) async {
    if (name.trim().isEmpty) {
      _error = 'Please enter a display name';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await _authService.signInAnonymous(name.trim());
      if (user != null) {
        _displayName = name.trim();
      }
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _error = 'Sign-in failed';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _displayName = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
