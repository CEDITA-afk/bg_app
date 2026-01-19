import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';

class MonsterWidget extends StatelessWidget {
  const MonsterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    double hpPercent = (game.monsterMaxHp > 0) ? (game.monsterHp / game.monsterMaxHp).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.black.withOpacity(0.8),
      child: Column(
        children: [
          Text(game.monsterName.toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: hpPercent, minHeight: 15, color: Colors.red, backgroundColor: Colors.white10),
          const SizedBox(height: 10),
          
          // RISERVA OVERLORD
          const Text("RISERVA MANA OVERLORD", style: TextStyle(fontSize: 10, color: Colors.white54, letterSpacing: 1.2)),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: game.overlordManaPool.entries.map((e) => _manaBadge(e.key, e.value)).toList(),
          )
        ],
      ),
    );
  }

  Widget _manaBadge(String type, int count) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: _getManaColor(type), borderRadius: BorderRadius.circular(4)),
      child: Text("$count", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Color _getManaColor(String t) {
    switch(t) {
      case 'R': return Colors.red; case 'B': return Colors.blue;
      case 'G': return Colors.green; case 'Y': return Colors.yellow;
      case 'K': return Colors.purpleAccent; // Ombra
      default: return Colors.grey;
    }
  }
}