import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';

class LogWidget extends StatelessWidget {
  const LogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Container(
      width: double.infinity,
      color: Colors.black.withOpacity(0.5),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: game.logs.length,
        itemBuilder: (context, index) {
          final log = game.logs[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("[${log['type']}] ", 
                  style: TextStyle(color: _getLogColor(log['type']!), fontSize: 10, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(log['msg']!, 
                    style: const TextStyle(color: Colors.white70, fontSize: 10)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getLogColor(String type) {
    switch(type) {
      case 'DMG': return Colors.redAccent;
      case 'ENERGY': return Colors.yellowAccent;
      case 'OVERLORD': return Colors.purpleAccent;
      case 'ROUND': return Colors.blueAccent;
      default: return Colors.grey;
    }
  }
}