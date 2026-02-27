// RevenueCat stubs — no-op implementation.
// Replace with real purchases_flutter calls when going to production.
class SubscriptionService {
  Future<bool> initialize() async => false;

  Future<bool> isPremiumUser() async => false;

  Future<bool> hasEntitlement(String entitlementId) async => false;

  Future<DateTime?> getEntitlementExpirationDate(String entitlementId) async => null;

  Future<List<dynamic>> getAvailablePackages() async => [];

  Future<dynamic> purchaseProduct(String productId) async => null;

  Future<bool> presentPaywall({String? offeringId}) async => false;

  Future<dynamic> restorePurchases() async => null;

  Future<void> setUserID(String userId) async {}

  Future<void> logout() async {}

  Future<void> presentCustomerCenter() async {}
}
