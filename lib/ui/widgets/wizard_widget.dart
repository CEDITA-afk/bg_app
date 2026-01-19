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
    final wiz = game.wizards[wizardIndex];
    final bool isActive = game.activeWizardIndex == wizardIndex;

    return Opacity(
      opacity: isActive ? 1.0 : 0.6, // Oscura chi non è di turno
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: wiz.isSpirit ? Colors.blueGrey.shade900 : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isActive ? Colors.yellowAccent : (wiz.isSpirit ? Colors.white24 : Colors.blueAccent.withOpacity(0.3)),
            width: isActive ? 2 : 1
          ),
        ),
        child: Column(
          children: [
            _buildHeroHeader(wiz, isActive),
            const SizedBox(height: 10),
            _buildDiceArea(context, game, wiz, isActive),
            const Divider(color: Colors.white10, height: 20),
            _buildDicePicker(game, wiz, isActive),
            const SizedBox(height: 10),
            // GRIGLIA MAGIE
            Expanded(child: _buildSpellsGrid(game, wiz, isActive)),
            _buildFooter(game, wiz, isActive),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(Wizard wiz, bool isActive) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(wiz.isSpirit ? "${wiz.className} (SPIRITO)" : wiz.className, 
                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: wiz.isSpirit ? Colors.white54 : Colors.blueAccent)),
            if (isActive) const Icon(Icons.star, color: Colors.yellowAccent, size: 18),
            Row(children: [
              const Icon(Icons.bolt, color: Colors.yellowAccent, size: 16),
              Text("${wiz.stamina}", style: const TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold)),
            ]),
          ],
        ),
        const SizedBox(height: 5),
        LinearProgressIndicator(value: wiz.hp / wiz.maxHp, minHeight: 6, color: Colors.green, backgroundColor: Colors.white10),
      ],
    );
  }

  Widget _buildDiceArea(BuildContext context, GameProvider game, Wizard wiz, bool isActive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(children: [
          const Text("ACCUMULO", style: TextStyle(fontSize: 8, color: Colors.grey)),
          Wrap(spacing: 4, children: wiz.savedDice.map((d) => _die(d, true, null)).toList()),
        ]),
        Column(children: [
          const Text("LANCIO (Clicca per Salvare ⚡)", style: TextStyle(fontSize: 8, color: Colors.grey)),
          Wrap(spacing: 4, children: wiz.currentRoll.asMap().entries.map((e) => 
            _die(e.value, false, isActive ? () => game.saveDie(wizardIndex, e.key) : null)).toList()),
        ]),
      ],
    );
  }

  Widget _buildDicePicker(GameProvider game, Wizard wiz, bool isActive) {
    final dice = ['R', 'B', 'G', 'Y'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: dice.map((d) {
        bool sel = wiz.selectedDiceForRoll.contains(d);
        return GestureDetector(
          onTap: isActive ? () => game.toggleDiceSelection(wizardIndex, d) : null,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 35, height: 35,
            decoration: BoxDecoration(color: _getDieColor(d).withOpacity(sel ? 1 : 0.2), borderRadius: BorderRadius.circular(6), border: sel ? Border.all(color: Colors.white) : null),
            child: Center(child: Text(d, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSpellsGrid(GameProvider game, Wizard wiz, bool isActive) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.8
      ),
      itemCount: wiz.spells.length,
      itemBuilder: (context, index) {
        final spell = wiz.spells[index];
        bool isCastable = game.canWizardCast(wizardIndex, spell);
        return _spellCard(game, spell, isCastable && isActive);
      },
    );
  }

  Widget _spellCard(GameProvider game, Spell spell, bool highlight) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: highlight ? Colors.blueAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: highlight ? Colors.yellowAccent : Colors.transparent, width: 2),
      ),
      child: Column(
        children: [
          Text(spell.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const Spacer(),
          ElevatedButton(
            onPressed: highlight ? () => game.castSpell(spell, wizardIndex) : null,
            style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(double.infinity, 30)),
            child: const Text("LANCIA", style: TextStyle(fontSize: 10)),
          )
        ],
      ),
    );
  }

  Widget _buildFooter(GameProvider game, Wizard wiz, bool isActive) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: isActive && wiz.selectedDiceForRoll.isNotEmpty ? () => game.rollDice(wizardIndex) : null,
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 35)),
          child: const Text("CONFERMA LANCIO"),
        ),
        if (isActive) ...[
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => game.endPlayerTurn(), // METODO ORA DEFINITO NEL PROVIDER
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[900], minimumSize: const Size(double.infinity, 35)),
            child: const Text("FINE TURNO EROE"),
          ),
        ]
      ],
    );
  }

  Widget _die(String l, bool s, VoidCallback? t) {
    return GestureDetector(
      onTap: t,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(color: _getDieColor(l), borderRadius: BorderRadius.circular(4), border: s ? Border.all(color: Colors.white, width: 2) : null),
        child: Center(child: Text(l, style: TextStyle(color: l == 'K' ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 12))),
      ),
    );
  }

  Color _getDieColor(String t) {
    switch(t) {
      case 'R': return Colors.red; case 'B': return Colors.blue;
      case 'G': return Colors.green; case 'Y': return Colors.yellow;
      case 'K': return Colors.purpleAccent; default: return Colors.grey;
    }
  }
}