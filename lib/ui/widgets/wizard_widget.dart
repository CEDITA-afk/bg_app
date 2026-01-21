import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../models/wizard.dart';
import '../../models/spell.dart';

class WizardZoneWidget extends StatelessWidget {
  final int wizardIndex;
  const WizardZoneWidget({super.key, required this.wizardIndex});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    
    if (wizardIndex >= game.wizards.length) return const SizedBox();
    
    final wiz = game.wizards[wizardIndex];
    final bool isActive = game.activeWizardIndex == wizardIndex;

    return Opacity(
      opacity: isActive ? 1.0 : 0.6,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.blueAccent : Colors.white10, 
            width: 2
          ),
          boxShadow: isActive ? [
            BoxShadow(color: Colors.blueAccent.withOpacity(0.1), blurRadius: 20)
          ] : [],
        ),
        child: Column(
          children: [
            _buildHeroHeader(wiz),
            const SizedBox(height: 12),
            _buildStatsRow(wiz),
            const Divider(color: Colors.white10, height: 24),
            _buildDiceSection(context, game, wiz, isActive),
            const SizedBox(height: 16),
            
            // Griglia delle Magie
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  crossAxisSpacing: 10, 
                  mainAxisSpacing: 10, 
                  childAspectRatio: 0.72
                ),
                itemCount: wiz.spells.length,
                itemBuilder: (context, index) {
                  final spell = wiz.spells[index];
                  bool canCast = game.canWizardCast(wizardIndex, spell) && wiz.actions > 0;
                  return _spellCard(game, spell, canCast && isActive);
                },
              ),
            ),
            
            _buildActionFooter(game, wiz, isActive),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(Wizard wiz) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          wiz.className.toUpperCase(), 
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.blueAccent)
        ),
        Icon(Icons.circle, color: wiz.isSpirit ? Colors.white24 : Colors.greenAccent, size: 12),
      ],
    );
  }

  Widget _buildStatsRow(Wizard wiz) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statTile("HP", "${wiz.hp}/12", Colors.redAccent),
        // Visualizzazione dell'energia come contatore accumulabile
        _statTile("ENERGIA", "${wiz.stamina}", Colors.yellowAccent),
        _statTile("AZIONI", "${wiz.actions}/2", Colors.orangeAccent),
      ],
    );
  }

  Widget _statTile(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.white38)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildDiceSection(BuildContext context, GameProvider game, Wizard wiz, bool isActive) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _diceGroup("ACCUMULO", wiz.savedDice, isActive, (idx) => game.unsaveDie(wizardIndex, idx)),
            _diceGroup("LANCIO", wiz.currentRoll, isActive, (idx) => _showDiceOptions(context, game, idx)),
          ],
        ),
        if (game.currentPhase == GamePhase.playerRoll && isActive) 
          _buildDicePicker(game, wiz, isActive),
      ],
    );
  }

  Widget _diceGroup(String label, List<String> dice, bool active, Function(int) onTap) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.white38)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 4,
          children: dice.asMap().entries.map((e) => 
            _dieWidget(e.value, label == "ACCUMULO", active ? () => onTap(e.key) : null)
          ).toList(),
        ),
      ],
    );
  }

  void _showDiceOptions(BuildContext context, GameProvider game, int dieIdx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.save, color: Colors.greenAccent),
              title: const Text("Salva in Accumulo (Costa 1⚡ Energia)"),
              onTap: () { game.saveDie(wizardIndex, dieIdx); Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.bolt, color: Colors.yellowAccent),
              title: const Text("Converti in Energia (+1⚡ Energia)"),
              onTap: () { game.convertDieToEnergy(wizardIndex, dieIdx); Navigator.pop(context); },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDicePicker(GameProvider game, Wizard wiz, bool isActive) {
    final dice = ['R', 'B', 'G', 'Y'];
    int limit = wiz.diceToRollLimit;
    int selected = wiz.selectedDiceForRoll.length;

    return Column(
      children: [
        const SizedBox(height: 12),
        Text("SELEZIONA DADI ($selected/$limit)", 
          style: const TextStyle(fontSize: 9, color: Colors.white54, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: dice.map((d) {
            bool sel = wiz.selectedDiceForRoll.contains(d);
            return GestureDetector(
              onTap: isActive ? () => game.toggleDiceSelection(wizardIndex, d) : null,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 35, height: 35,
                decoration: BoxDecoration(
                  color: _getDieColor(d).withOpacity(sel ? 1 : 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: sel ? Border.all(color: Colors.white, width: 2) : null,
                ),
                child: Center(child: Text(d, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
              ),
            );
          }).toList(),
        ),
        TextButton(
          onPressed: isActive && wiz.selectedDiceForRoll.isNotEmpty ? () => game.rollDice(wizardIndex) : null,
          child: const Text("CONFERMA LANCIO DADI", 
            style: TextStyle(fontSize: 10, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _spellCard(GameProvider game, Spell spell, bool active) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: active ? Colors.blueAccent.withOpacity(0.15) : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? Colors.yellowAccent : Colors.transparent, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(spell.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), maxLines: 1),
          const SizedBox(height: 4),
          _manaCostRow(spell.cost),
          const Spacer(),
          Text(spell.description, style: const TextStyle(fontSize: 8, color: Colors.white54), maxLines: 3),
          const SizedBox(height: 6),
          ElevatedButton(
            onPressed: active ? () => game.castSpell(spell, wizardIndex) : null,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero, 
              minimumSize: const Size(double.infinity, 28),
              backgroundColor: active ? Colors.blueAccent.shade700 : Colors.grey.shade800,
            ),
            child: const Text("LANCIA", style: TextStyle(fontSize: 9)),
          ),
        ],
      ),
    );
  }

  Widget _manaCostRow(Map<String, int> cost) {
    return Wrap(
      children: cost.entries.map((e) => Container(
        margin: const EdgeInsets.only(right: 2),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(color: _getDieColor(e.key), borderRadius: BorderRadius.circular(3)),
        child: Text("${e.value}", style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
      )).toList(),
    );
  }

  Widget _buildActionFooter(GameProvider game, Wizard wiz, bool isActive) {
    if (!isActive || game.currentPhase == GamePhase.playerRoll) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ElevatedButton(
        onPressed: () => game.endPlayerTurn(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey[900], 
          minimumSize: const Size(double.infinity, 40)
        ),
        child: const Text("CONCLUDI FASE AZIONI", 
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _dieWidget(String label, bool saved, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26, height: 26,
        decoration: BoxDecoration(
          color: _getDieColor(label),
          borderRadius: BorderRadius.circular(4),
          border: saved ? Border.all(color: Colors.white, width: 1.5) : null,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
        ),
        child: Center(
          child: Text(label, 
            style: TextStyle(
              color: label == 'K' ? Colors.white : Colors.black, 
              fontWeight: FontWeight.bold, 
              fontSize: 12
            )
          )
        ),
      ),
    );
  }

  Color _getDieColor(String t) {
    switch(t) {
      case 'R': return Colors.redAccent;
      case 'B': return Colors.blueAccent;
      case 'G': return Colors.greenAccent;
      case 'Y': return Colors.yellowAccent;
      case 'K': return Colors.purpleAccent;
      default: return Colors.grey;
    }
  }
}