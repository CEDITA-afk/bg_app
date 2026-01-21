import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../models/monster.dart';

class MonsterWidget extends StatelessWidget {
  const MonsterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final boss = game.boss;
    double hpPercent = (boss.maxHp > 0) ? (boss.hp / boss.maxHp).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(bottom: BorderSide(color: Colors.red.shade900, width: 3)),
      ),
      child: Column(
        children: [
          _buildHeader(boss, game.overlordTokens),
          const SizedBox(height: 12),
          _buildHpBar(hpPercent, context),
          const SizedBox(height: 12),
          const Text("RISERVA MANA OVERLORD (SCAMBIO EQUIVALENTE)", 
            style: TextStyle(fontSize: 8, color: Colors.white38, letterSpacing: 1)),
          const SizedBox(height: 8),
          _buildManaPool(boss.manaPool),
          if (game.currentPhase == GamePhase.overlordReaction) ...[
            const Divider(color: Colors.white10, height: 24),
            _buildAbilities(game, boss),
            const SizedBox(height: 12),
            _buildConcludeButton(game),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(Monster boss, int tokens) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(boss.name.toUpperCase(), 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
            Text("FASE ${boss.phase} • DIFESA ${boss.defense}", 
              style: const TextStyle(fontSize: 9, color: Colors.white54, letterSpacing: 1)),
          ],
        ),
        Row(
          children: List.generate(tokens, (i) => 
            const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.hourglass_full, color: Colors.purpleAccent, size: 16))
          ),
        ),
      ],
    );
  }

  Widget _buildHpBar(double percent, BuildContext context) {
    return Stack(
      children: [
        Container(height: 10, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          height: 10,
          width: MediaQuery.of(context).size.width * percent,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.red.shade900, Colors.redAccent]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildManaPool(Map<String, int> pool) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pool.entries.map((e) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: _getManaColor(e.key), borderRadius: BorderRadius.circular(4)),
        child: Text("${e.value}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
      )).toList(),
    );
  }

  Widget _buildAbilities(GameProvider game, Monster boss) {
    return Column(
      children: [
        const Text("ABILITÀ DI REAZIONE", style: TextStyle(fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: boss.abilities.map((ability) {
            bool canAfford = game.canMonsterAfford(ability);
            return ElevatedButton(
              onPressed: canAfford ? () => game.executeMonsterAbility(ability) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900.withOpacity(canAfford ? 1 : 0.3),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(100, 36),
              ),
              child: Text(ability.name, style: const TextStyle(fontSize: 9)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConcludeButton(GameProvider game) {
    return ElevatedButton(
      onPressed: () => game.concludeOverlordReaction(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey[900],
        minimumSize: const Size(double.infinity, 36),
      ),
      child: const Text("CONCLUDI REAZIONE E PASSA TURNO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Color _getManaColor(String t) {
    switch(t) {
      case 'R': return Colors.redAccent; case 'B': return Colors.blueAccent;
      case 'G': return Colors.greenAccent; case 'Y': return Colors.yellowAccent;
      case 'K': return Colors.purpleAccent; default: return Colors.grey;
    }
  }
}