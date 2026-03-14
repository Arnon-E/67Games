import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../engine/types.dart';
import '../l10n/app_localizations.dart';
import '../state/game_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/screen_header.dart';

class _Item {
  final String id;
  final String nameKey;
  final String descKey;
  final String categoryKey;
  final String equipType; // matches equipCosmetic() type key
  final int price;
  final Color color;
  final bool comingSoon;
  const _Item({
    required this.id,
    required this.nameKey,
    required this.descKey,
    required this.price,
    required this.categoryKey,
    required this.equipType,
    required this.color,
    this.comingSoon = false,
  });
}

const _items = [
  _Item(id: 'timer_skin_neon', nameKey: 'neonTimer', descKey: 'neonTimerDesc',
      price: 1200, categoryKey: 'timerSkins', equipType: 'timerSkin', color: Color(0xFF00FFCC)),
  _Item(id: 'timer_skin_gold', nameKey: 'goldTimer', descKey: 'goldTimerDesc',
      price: 2400, categoryKey: 'timerSkins', equipType: 'timerSkin', color: Color(0xFFFFD700)),
  _Item(id: 'bg_purple', nameKey: 'purpleHaze', descKey: 'purpleHazeDesc',
      price: 1800, categoryKey: 'backgrounds', equipType: 'background', color: Color(0xFF8B5CF6)),
  _Item(id: 'bg_ocean', nameKey: 'oceanDeep', descKey: 'oceanDeepDesc',
      price: 1800, categoryKey: 'backgrounds', equipType: 'background', color: Color(0xFF0EA5E9)),
  _Item(id: 'celebration_fireworks', nameKey: 'fireworks', descKey: 'fireworksDesc',
      price: 3000, categoryKey: 'celebrations', equipType: 'celebration', color: Color(0xFFFF6B35),
      comingSoon: true),
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
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, color: AppColors.gold, size: 16),
                      const SizedBox(width: 8),
                      Text(l10n.shopCoins(gs.coins),
                          style: const TextStyle(
                              color: AppColors.gold, fontSize: 15, fontWeight: FontWeight.w600)),
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
                                color: AppColors.textDisabled, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        ...entry.value.map((item) => _ItemCard(
                              item: item,
                              name: _itemName(item, l10n),
                              description: _itemDesc(item, l10n),
                              ownedLabel: l10n.shopOwned,
                              equippedLabel: l10n.shopEquipped,
                              equipLabel: l10n.shopEquip,
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
  final String equippedLabel;
  final String equipLabel;
  final String purchasedMessage;

  const _ItemCard({
    required this.item,
    required this.name,
    required this.description,
    required this.ownedLabel,
    required this.equippedLabel,
    required this.equipLabel,
    required this.purchasedMessage,
  });

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final owned = gs.ownedCosmetics.contains(item.id);
    final canAfford = gs.coins >= item.price;
    final equipped = _equippedId(gs.loadout, item.equipType) == item.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: equipped
            ? Border.all(color: item.color, width: 1.5)
            : owned
                ? Border.all(color: item.color.withValues(alpha: 0.35))
                : null,
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: equipped ? 0.3 : 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: item.color.withValues(alpha: 0.4)),
            ),
            child: Icon(
              equipped ? Icons.check_circle : (owned ? Icons.check_circle_outline : Icons.circle_outlined),
              color: item.color, size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                Text(description, style: const TextStyle(color: AppColors.textDisabled, fontSize: 12)),
              ],
            ),
          ),
          if (item.comingSoon)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: AppColors.textHint, borderRadius: BorderRadius.circular(20)),
              child: const Text('Soon',
                  style: TextStyle(color: AppColors.textDisabled, fontSize: 12, fontWeight: FontWeight.w600)),
            )
          else if (equipped)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
              child: Text(equippedLabel,
                  style: TextStyle(color: item.color, fontSize: 12, fontWeight: FontWeight.w600)),
            )
          else if (owned)
            GestureDetector(
              onTap: () => gs.equipCosmetic(item.equipType, item.id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: item.color.withValues(alpha: 0.5))),
                child: Text(equipLabel,
                    style: TextStyle(color: item.color, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
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
                    color: canAfford ? AppColors.orange : AppColors.textHint,
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: canAfford ? AppColors.textPrimary : AppColors.textDisabled, size: 10),
                    const SizedBox(width: 4),
                    Text('${item.price}',
                        style: TextStyle(
                            color: canAfford ? AppColors.textPrimary : AppColors.textDisabled,
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String? _equippedId(PlayerLoadout loadout, String equipType) {
    return switch (equipType) {
      'timerSkin' => loadout.timerSkin,
      'background' => loadout.background,
      'soundPack' => loadout.soundPack,
      'celebration' => loadout.celebration,
      _ => null,
    };
  }
}
