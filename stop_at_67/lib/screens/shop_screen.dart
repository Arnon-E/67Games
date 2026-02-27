import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/game_state.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/screen_header.dart';

class _Item {
  final String id;
  final String nameKey;
  final String descKey;
  final String categoryKey;
  final int price;
  final Color color;
  const _Item({
    required this.id,
    required this.nameKey,
    required this.descKey,
    required this.price,
    required this.categoryKey,
    required this.color,
  });
}

const _items = [
  _Item(id: 'timer_skin_neon', nameKey: 'neonTimer', descKey: 'neonTimerDesc',
      price: 100, categoryKey: 'timerSkins', color: Color(0xFF00FFCC)),
  _Item(id: 'timer_skin_gold', nameKey: 'goldTimer', descKey: 'goldTimerDesc',
      price: 200, categoryKey: 'timerSkins', color: Color(0xFFFFD700)),
  _Item(id: 'bg_purple', nameKey: 'purpleHaze', descKey: 'purpleHazeDesc',
      price: 150, categoryKey: 'backgrounds', color: Color(0xFF8B5CF6)),
  _Item(id: 'bg_ocean', nameKey: 'oceanDeep', descKey: 'oceanDeepDesc',
      price: 150, categoryKey: 'backgrounds', color: Color(0xFF0EA5E9)),
  _Item(id: 'celebration_fireworks', nameKey: 'fireworks', descKey: 'fireworksDesc',
      price: 250, categoryKey: 'celebrations', color: Color(0xFFFF6B35)),
];

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  String _itemName(_Item item, AppLocalizations l10n) {
    return switch (item.nameKey) {
      'neonTimer' => l10n.shopItemNeonTimerName,
      'goldTimer' => l10n.shopItemGoldTimerName,
      'purpleHaze' => l10n.shopItemPurpleHazeName,
      'oceanDeep' => l10n.shopItemOceanDeepName,
      'fireworks' => l10n.shopItemFireworksName,
      _ => item.nameKey,
    };
  }

  String _itemDesc(_Item item, AppLocalizations l10n) {
    return switch (item.descKey) {
      'neonTimerDesc' => l10n.shopItemNeonTimerDesc,
      'goldTimerDesc' => l10n.shopItemGoldTimerDesc,
      'purpleHazeDesc' => l10n.shopItemPurpleHazeDesc,
      'oceanDeepDesc' => l10n.shopItemOceanDeepDesc,
      'fireworksDesc' => l10n.shopItemFireworksDesc,
      _ => item.descKey,
    };
  }

  String _categoryName(String key, AppLocalizations l10n) {
    return switch (key) {
      'timerSkins' => l10n.shopCategoryTimerSkins,
      'backgrounds' => l10n.shopCategoryBackgrounds,
      'celebrations' => l10n.shopCategoryCelebrations,
      _ => key,
    };
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final l10n = AppLocalizations.of(context);
    final categories = <String, List<_Item>>{};
    for (final item in _items) {
      categories.putIfAbsent(item.categoryKey, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(title: l10n.shopTitle, onBack: () => gs.setScreen(AppScreen.menu)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, color: Color(0xFFFFD700), size: 16),
                      const SizedBox(width: 8),
                      Text(l10n.shopCoins(gs.coins),
                          style: const TextStyle(
                              color: Color(0xFFFFD700), fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  children: categories.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_categoryName(entry.key, l10n).toUpperCase(),
                            style: const TextStyle(
                                fontSize: 11, letterSpacing: 2,
                                color: Colors.white38, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        ...entry.value.map((item) => _ItemCard(
                              item: item,
                              name: _itemName(item, l10n),
                              description: _itemDesc(item, l10n),
                              ownedLabel: l10n.shopOwned,
                              purchasedMessage: l10n.shopPurchased(_itemName(item, l10n)),
                            )),
                        const SizedBox(height: 20),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final _Item item;
  final String name;
  final String description;
  final String ownedLabel;
  final String purchasedMessage;

  const _ItemCard({
    required this.item,
    required this.name,
    required this.description,
    required this.ownedLabel,
    required this.purchasedMessage,
  });

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final owned = gs.ownedCosmetics.contains(item.id);
    final canAfford = gs.coins >= item.price;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(14),
        border: owned ? Border.all(color: item.color.withValues(alpha: 0.5)) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: item.color.withValues(alpha: 0.4)),
            ),
            child: Icon(owned ? Icons.check_circle : Icons.circle, color: item.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                Text(description, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          if (owned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
              child: Text(ownedLabel,
                  style: TextStyle(color: item.color, fontSize: 12, fontWeight: FontWeight.w600)),
            )
          else
            GestureDetector(
              onTap: canAfford ? () {
                final bought = gs.purchaseCosmetic(item.id, item.price);
                if (bought && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(purchasedMessage),
                        duration: const Duration(seconds: 2)));
                }
              } : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: canAfford ? const Color(0xFFFF6B35) : Colors.white12,
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: canAfford ? Colors.white : Colors.white38, size: 10),
                    const SizedBox(width: 4),
                    Text('${item.price}',
                        style: TextStyle(
                            color: canAfford ? Colors.white : Colors.white38,
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
