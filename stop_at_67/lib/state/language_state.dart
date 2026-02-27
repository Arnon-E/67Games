import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class LanguageState extends ChangeNotifier {
  final StorageService _storage;

  String _currentLanguage = 'en';
  bool _initialized = false;

  LanguageState(this._storage);

  String get currentLanguage => _currentLanguage;
  bool get isInitialized => _initialized;

  Locale get locale => Locale(_currentLanguage);

  bool get isRTL => _currentLanguage == 'he';

  Future<void> initialize() async {
    _currentLanguage = await _storage.loadLanguage();
    _initialized = true;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    if (_currentLanguage == code) return;
    _currentLanguage = code;
    await _storage.saveLanguage(code);
    notifyListeners();
  }
}
