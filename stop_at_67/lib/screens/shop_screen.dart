import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_state.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/screen_header.dart';

class _Item {
  final String id;
  final String name;
  final String description;
  final int price;
  final String category;
  final Color color;
  const _Item({required this.id, required this.name, required this.description,
      required this.price, required this.category, required this.color});
}

const _items = [
  _Item(id: 'timer_skin_neon', name: 'Neon Timer', description: 'Glowing neon display',
      price: 100, category: 'Timer Skins', color: Color(0xFF00FFCC)),
  _Item(id: 'timer_skin_gold', name: 'Gold Timer', description: 'Luxurious gold display',
      price: 200, category: 'Timer Skins', color: Color(0xFFFFD700)),
  _Item(id: 'bg_purple', name: 'Purple Haze', description: 'Deep purple background',
      price: 150, category: 'Backgrounds', color: Color(0xFF8B5CF6)),
  _Item(id: 'bg_ocean', name: 'Ocean Deep', description: 'Dark ocean theme',
      price: 150, category: 'Backgrounds', color: Color(0xFF0EA5E9)),
  _Item(id: 'celebration_fireworks', name: 'Fireworks', description: 'Celebrate with fireworks',
      price: 250, category: 'Celebrations', color: Color(0xFFFF6B35)),
];

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final categories = <String, List<_Item>>{};
    for (final item in _items) {
      categories.putIfAbsent(item.category, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(title: 'Shop', onBack: () => gs.setScreen(AppScreen.menu)),
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
                      Text('${gs.coins} coins',
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
                        Text(entry.key.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 11, letterSpacing: 2,
                                color: Colors.white38, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        ...entry.value.map((item) => _ItemCard(item: item)),
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
  const _ItemCard({required this.item});

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
                Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                Text(item.description, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          if (owned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
              child: Text('Owned',
                  style: TextStyle(color: item.color, fontSize: 12, fontWeight: FontWeight.w600)),
            )
          else
            GestureDetector(
              onTap: canAfford ? () {
                final bought = gs.purchaseCosmetic(item.id, item.price);
                if (bought && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.name} purchased!'),
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
