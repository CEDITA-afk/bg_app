import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'widgets/monster_widget.dart';
import 'widgets/log_widget.dart';
import 'widgets/wizard_widget.dart';

class ArenaScreen extends StatelessWidget {
  const ArenaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("MANA ECHO - ARENA", style: TextStyle(letterSpacing: 1.5, fontSize: 16)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white24),
            onPressed: () => game.initializeGame(),
          )
        ],
      ),
      body: Column(
        children: [
          // SEZIONE BOSS
          const MonsterWidget(),
          
          // CRONOLOGIA EVENTI
          const Expanded(flex: 1, child: LogWidget()),

          // SEZIONE EROE ATTIVO
          Expanded(
            flex: 4,
            child: game.wizards.isEmpty
                ? _buildSetup(context, game)
                : Column(
                    children: [
                      Expanded(
                        child: WizardZoneWidget(wizardIndex: game.activeWizardIndex),
                      ),
                      _buildOverlordControl(game),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetup(BuildContext context, GameProvider game) {
    return Center(
      child: ElevatedButton(
        onPressed: () => _showAddHeroMenu(context, game),
        child: const Text("AGGIUNGI EROI PER IL TEST"),
      ),
    );
  }

  // Pulsante per gestire la reazione dell'Overlord intercalata
  Widget _buildOverlordControl(GameProvider game) {
    if (game.currentPhase != GamePhase.overlordReaction) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.red.withOpacity(0.1),
      child: ElevatedButton(
        onPressed: () => game.concludeOverlordReaction(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[900],
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text("CONCLUDI REAZIONE OVERLORD", 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  void _showAddHeroMenu(BuildContext context, GameProvider game) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("SELEZIONA EROE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            ...game.availableClasses.map((cls) => ListTile(
              title: Text(cls['name']!),
              leading: const Icon(Icons.bolt, color: Colors.orangeAccent),
              onTap: () {
                game.addWizard(cls['name']!, cls['file']!);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }
}