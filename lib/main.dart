import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'ui/widgets/monster_widget.dart';
import 'ui/widgets/log_widget.dart';
import 'ui/widgets/wizard_widget.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameProvider()..initializeGame(),
      child: const BoardgameApp(),
    ),
  );
}

class BoardgameApp extends StatelessWidget {
  const BoardgameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.blueAccent,
      ),
      home: const ArenaScreen(),
    );
  }
}

class ArenaScreen extends StatelessWidget {
  const ArenaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("MANA ECHO - TEST ARENA"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () => _showClassPicker(context, game),
          )
        ],
      ),
      body: Column(
        children: [
          const MonsterWidget(),
          const Expanded(flex: 1, child: LogWidget()),
          
          Expanded(
            flex: 4,
            child: game.wizards.isEmpty
                ? _buildWelcome(context, game)
                : PageView.builder(
                    itemCount: game.wizards.length,
                    controller: PageController(viewportFraction: 0.9),
                    itemBuilder: (context, index) => WizardZoneWidget(wizardIndex: index),
                  ),
          ),

          // BARRA FINE TURNO (Sequenziale)
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.black,
            child: ElevatedButton.icon(
              onPressed: game.wizards.isNotEmpty ? () => game.resetTurn() : null,
              icon: const Icon(Icons.skip_next),
              label: Text(game.wizards.isEmpty 
                  ? "AGGIUNGI EROI" 
                  : "FINE TURNO: ${game.wizards[game.activeWizardIndex].className}"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[900],
                minimumSize: const Size(double.infinity, 45)
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWelcome(BuildContext context, GameProvider game) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_fix_high, size: 80, color: Colors.blueAccent),
          const SizedBox(height: 16),
          const Text("Aggiungi i 2 personaggi per il test.", style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showClassPicker(context, game),
            child: const Text("SCEGLI CLASSE"),
          ),
        ],
      ),
    );
  }

  void _showClassPicker(BuildContext context, GameProvider game) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20),
        children: [
          const Text("SELEZIONA MAGO", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...game.availableClasses.map((cls) => Card(
            color: Colors.white10,
            child: ListTile(
              leading: const Icon(Icons.bolt, color: Colors.orangeAccent),
              title: Text(cls['name']!),
              onTap: () {
                game.addWizard(cls['name']!, cls['file']!);
                Navigator.pop(context);
              },
            ),
          )).toList(),
        ],
      ),
    );
  }
}