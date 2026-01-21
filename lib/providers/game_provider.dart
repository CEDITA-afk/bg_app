import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wizard.dart';
import '../models/monster.dart';
import '../models/spell.dart';
import '../logic/dice_engine.dart';
import '../logic/mana_engine.dart';
import '../logic/combat_engine.dart';

enum GamePhase { playerRoll, playerActions, overlordReaction, maintenance }

class GameProvider extends ChangeNotifier {
  GamePhase currentPhase = GamePhase.playerRoll;
  int activeWizardIndex = 0;
  int overlordTokens = 0;
  List<Map<String, String>> logs = [];
  Monster boss = Monster(); 
  List<Wizard> wizards = [];

  final List<Map<String, String>> availableClasses = [
    {"name": "Piromante (Rosso)", "file": "spells_red.json"},
    {"name": "Biomante (Verde)", "file": "spells_green.json"},
    {"name": "Idromante (Blu)", "file": "spells_blue.json"},
    {"name": "Elettromante (Giallo)", "file": "spells_yellow.json"},
  ];

  Future<void> initializeGame() async {
    boss = Monster();
    wizards = [];
    activeWizardIndex = 0;
    overlordTokens = 0;
    currentPhase = GamePhase.playerRoll;
    logs = [{"type": "INFO", "msg": "⚔️ Mana Echo v2.0: Test Arena Pronto."}];
    notifyListeners();
  }

 Future<void> addWizard(String className, String fileName) async {
  final wiz = Wizard(className: className, jsonPath: "assets/data/$fileName");
  try {
    debugPrint("Caricamento file: ${wiz.jsonPath}"); // Debug log
    final String response = await rootBundle.loadString(wiz.jsonPath);
    final List<dynamic> data = json.decode(response);
    
    wiz.spells = data.map((s) => Spell.fromJson(s)).toList();
    wizards.add(wiz);
    
    addLog("INFO", "✨ $className pronto.");
    notifyListeners();
  } catch (e) {
    debugPrint("ERRORE CARICAMENTO: $e"); // Questo ti dirà il problema esatto
    addLog("ERROR", "Errore caricamento eroe ($className).");
  }
 }

  // --- LOGICA DADI ---
  void toggleDiceSelection(int wizIdx, String color) {
    if (wizIdx != activeWizardIndex || currentPhase != GamePhase.playerRoll) return;
    final wiz = wizards[wizIdx];
    int limit = wiz.diceToRollLimit;

    if (wiz.selectedDiceForRoll.contains(color)) {
      wiz.selectedDiceForRoll.remove(color);
    } else if (wiz.selectedDiceForRoll.length < limit) {
      wiz.selectedDiceForRoll.add(color);
    }
    notifyListeners();
  }

  void rollDice(int wizIdx) {
    if (wizIdx != activeWizardIndex || currentPhase != GamePhase.playerRoll) return;
    final wiz = wizards[wizIdx];
    if (wiz.selectedDiceForRoll.isEmpty) return;

    wiz.currentRoll = wiz.selectedDiceForRoll.map((c) => DiceEngine.rollDirty(c)).toList();
    wiz.selectedDiceForRoll.clear();
    currentPhase = GamePhase.playerActions;
    addLog("INFO", "${wiz.className} lancia ${wiz.currentRoll.length} dadi.");
    notifyListeners();
  }

  // --- ENERGIA E CONCENTRAZIONE ---
  void saveDie(int wizIdx, int dieIdx) {
    if (wizIdx != activeWizardIndex) return;
    final wiz = wizards[wizIdx];
    if (wiz.stamina >= 1) {
      wiz.savedDice.add(wiz.currentRoll.removeAt(dieIdx));
      wiz.stamina -= 1;
      notifyListeners();
    }
  }

  void convertDieToEnergy(int wizIdx, int dieIdx) {
    if (wizIdx != activeWizardIndex) return;
    final wiz = wizards[wizIdx];
    wiz.currentRoll.removeAt(dieIdx);
    wiz.stamina += 1; // Accumulo senza limite 2/2
    addLog("STAMINA", "+1⚡ Energia.");
    notifyListeners();
  }

  void unsaveDie(int wizIdx, int dieIdx) {
    if (wizIdx != activeWizardIndex) return;
    final wiz = wizards[wizIdx];
    wiz.currentRoll.add(wiz.savedDice.removeAt(dieIdx));
    notifyListeners();
  }

  // --- AZIONI E TURNI ---
  bool canWizardCast(int wizIdx, Spell spell) {
    final wiz = wizards[wizIdx];
    return ManaEngine.canAfford([...wiz.currentRoll, ...wiz.savedDice], spell.cost);
  }

  void castSpell(Spell spell, int wizIdx) {
    if (wizIdx != activeWizardIndex || currentPhase != GamePhase.playerActions) return;
    final wiz = wizards[wizIdx];
    if (wiz.actions <= 0 || !canWizardCast(wizIdx, spell)) return;

    _transferManaToOverlord(wiz, spell.cost);
    wiz.actions -= 1;
    
    int val = ((spell.effects[0]['value'] ?? 0) as num).toInt();
    int d = CombatEngine.calculateDamage(val, boss.defense);
    boss.hp -= d;
    
    addLog("DMG", "💥 ${spell.name}: -$d HP.");
    if (boss.hp <= 0 && boss.phase == 1) boss.nextPhase();
    notifyListeners();
  }

  void _transferManaToOverlord(Wizard wiz, Map<String, int> cost) {
    cost.forEach((color, amount) {
      if (color == 'ANY') return;
      for (int i = 0; i < amount; i++) {
        String die = wiz.currentRoll.contains(color) ? color : (wiz.savedDice.contains(color) ? color : 'K');
        if (!wiz.currentRoll.remove(die)) wiz.savedDice.remove(die);
        boss.addMana(die, 1);
      }
    });
    if (cost.containsKey('ANY')) {
      for (int i = 0; i < cost['ANY']!; i++) {
        String die = wiz.currentRoll.isNotEmpty ? wiz.currentRoll.removeAt(0) : wiz.savedDice.removeAt(0);
        boss.addMana(die, 1);
      }
    }
  }

  // --- LOGICA OVERLORD ---
  bool canMonsterAfford(MonsterAbility ability) {
    List<String> bossPool = [];
    boss.manaPool.forEach((color, count) {
      for (int i = 0; i < count; i++) bossPool.add(color);
    });
    return ManaEngine.canAfford(bossPool, ability.cost);
  }

  void executeMonsterAbility(MonsterAbility ability) {
    if (currentPhase != GamePhase.overlordReaction) return;
    if (!canMonsterAfford(ability)) return;

    ability.cost.forEach((color, amount) {
      for (int i = 0; i < amount; i++) {
        String keyToConsume = color == 'ANY' 
            ? boss.manaPool.keys.firstWhere((k) => boss.manaPool[k]! > 0)
            : (boss.manaPool[color]! > 0 ? color : 'K');
        boss.manaPool[keyToConsume] = boss.manaPool[keyToConsume]! - 1;
      }
    });
    addLog("OVERLORD", "🌩️ Boss usa ${ability.name}");
    notifyListeners();
  }

  void endPlayerTurn() {
    currentPhase = GamePhase.overlordReaction;
    notifyListeners();
  }

  void concludeOverlordReaction() {
    if (activeWizardIndex < wizards.length - 1) {
      activeWizardIndex++;
      currentPhase = GamePhase.playerRoll;
      wizards[activeWizardIndex].actions = 2;
    } else {
      _runMaintenance();
    }
    notifyListeners();
  }

  void _runMaintenance() {
    activeWizardIndex = 0;
    overlordTokens += 1;
    boss.addMana('K', 2); 
    for (var wiz in wizards) { wiz.actions = 2; }
    currentPhase = GamePhase.playerRoll;
    addLog("ROUND", "Fine Round. Overlord +1 ⌛.");
    notifyListeners();
  }

  void addLog(String type, String msg) {
    logs.insert(0, {"type": type, "msg": msg});
    notifyListeners();
  }
}