import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';

class LogWidget extends StatelessWidget {
  const LogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.black87,
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: game.logs.length,
        itemBuilder: (context, index) {
          final log = game.logs[index];
          final String type = log['type'] ?? 'INFO';
          final String message = log['msg'] ?? '';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Text(
              "> $message",
              style: TextStyle(
                color: _getLogColor(type),
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: type == 'DMG' ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  // Funzione per determinare il colore del testo come nel tuo progetto originale
  Color _getLogColor(String type) {
    switch (type) {
      case 'DMG':
        return Colors.redAccent;
      case 'HEAL':
        return Colors.greenAccent;
      case 'STATUS':
        return Colors.orangeAccent;
      case 'ENERGY':
        return Colors.lightBlueAccent;
      case 'ERROR':
        return Colors.deepOrange;
      default:
        return Colors.white70;
    }
  }
}