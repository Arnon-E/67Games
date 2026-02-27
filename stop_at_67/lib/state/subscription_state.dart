import 'package:flutter/material.dart';
import '../services/subscription_service.dart';

class SubscriptionState extends ChangeNotifier {
  final SubscriptionService _service;

  bool _isPremium = false;
  DateTime? _expirationDate;

  SubscriptionState(this._service);

  bool get isPremium => _isPremium;
  DateTime? get expirationDate => _expirationDate;

  Future<void> initialize() async {
    _isPremium = await _service.isPremiumUser();
    notifyListeners();
  }

  Future<bool> restorePurchases() async {
    await _service.restorePurchases();
    _isPremium = await _service.isPremiumUser();
    notifyListeners();
    return _isPremium;
  }

  Future<void> logout() async {
    await _service.logout();
    _isPremium = false;
    _expirationDate = null;
    notifyListeners();
  }
}
