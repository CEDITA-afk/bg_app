// lib/game_state.dart

import 'package:flutter/material.dart';
import 'models.dart';
import 'dart:math';

class GameState extends ChangeNotifier {
  // Mostro attuale (ispirato a monster.js)
  String monsterName = "Golem di Ferro";
  int monsterHp = 50;
  int monsterMaxHp = 50;
  
  // Lista dei maghi attivi (ispirato a player.js)
  List<Wizard> wizards = [];

  // Log dei messaggi (ispirato a utils.js)
  List<String> combatLog = ["Sistema Inizializzato."];

  void addWizard(String className) {
    wizards.add(Wizard(className: className));
    addLog("Un $className è entrato in battaglia!");
    notifyListeners(); // Questo aggiorna l'interfaccia
  }

  void addLog(String message) {
    combatLog.insert(0, message); // Mette il messaggio più recente in alto
    notifyListeners();
  }

  // Logica del lancio dadi (Traduzione di rollAll in player.js)
  void rollDice(int wizardIndex) {
    final wiz = wizards[wizardIndex];
    final random = Random();
    final colors = ['R', 'G', 'B', 'Y', 'W'];
    
    wiz.currentRoll = List.generate(3, (_) => colors[random.nextInt(colors.length)]);
    wiz.hasRolled = true;
    
    addLog("${wiz.className} ha lanciato i dadi: ${wiz.currentRoll.join(', ')}");
    notifyListeners();
  }
}