import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/wizard.dart';
import '../models/spell.dart';
import '../logic/mana_engine.dart';
import '../logic/combat_engine.dart';

class GameProvider extends ChangeNotifier {
  // --- CONFIGURAZIONE CLASSI ---
  final List<Map<String, String>> availableClasses = [
    {"name": "Piromante (Rosso)", "file": "spells_red.json"},
    {"name": "Biomante (Verde)", "file": "spells_green.json"},
  ];

  // --- STATO OVERLORD (Fase 3: Scambio Equivalente) ---
  Map<String, int> overlordManaPool = {'R': 0, 'B': 0, 'G': 0, 'Y': 0, 'K': 0};

  // --- STATO DEL MOSTRO ---
  String monsterName = "Caricamento...";
  int monsterHp = 0;
  int monsterMaxHp = 0;
  int monsterDefense = 0;
  Map<String, int> monsterStatuses = {};

  // --- STATO DEI GIOCATORI ---
  List<Wizard> wizards = [];
  List<Map<String, String>> logs = [];
  
  // Indice del giocatore che sta agendo
  int activeWizardIndex = 0;

  // --- INIZIALIZZAZIONE ---
  Future<void> initializeGame() async {
    try {
      final String response = await rootBundle.loadString('assets/data/monsters.json');
      final List<dynamic> data = json.decode(response);
      
      final monsterData = data[1]; 
      monsterName = monsterData['name'];
      monsterMaxHp = monsterData['hp'];
      monsterHp = monsterData['hp'];
      monsterDefense = monsterData['defense'];
      
      overlordManaPool = {'R': 0, 'B': 0, 'G': 0, 'Y': 0, 'K': 0};
      wizards = [];
      activeWizardIndex = 0;
      monsterStatuses = {};
      logs = [{"type": "INFO", "msg": "⚔️ Mana Echo v2.0: Modalità Turni Sequenziali."}];
      notifyListeners();
    } catch (e) {
      debugPrint("Errore inizializzazione: $e");
      addLog("ERROR", "❌ Errore nel caricamento dei dati iniziali.");
    }
  }

  Future<void> addWizard(String className, String fileName) async {
    final String path = "assets/data/$fileName"; 
    final wiz = Wizard(className: className, jsonPath: path);

    try {
      final String response = await rootBundle.loadString(path);
      final List<dynamic> data = json.decode(response);
      
      wiz.spells = data.map((s) => Spell.fromJson(s)).toList();
      wizards.add(wiz);
      
      addLog("INFO", "✨ $className si è unito alla battaglia!");
      notifyListeners();
    } catch (e) {
      addLog("ERROR", "❌ Impossibile caricare l'eroe: $path");
    }
  }

  // --- LOGICA DIRTY DICE (Regolamento 2.1) ---
  String _rollDirtyDie(String dieColor) {
    final random = Random();
    int result = random.nextInt(6) + 1; // D6: 1-6

    if (result == 1) {
      return 'K'; // JOLLY/OMBRA (Nero)
    } else if (result <= 3) {
      return dieColor; // PURO
    } else {
      // IBRIDO: un colore elementale diverso
      List<String> others = ['R', 'B', 'G', 'Y'];
      others.remove(dieColor);
      return others[random.nextInt(others.length)];
    }
  }

  void toggleDiceSelection(int wizIndex, String color) {
    if (wizIndex != activeWizardIndex) return; // Solo chi è di turno agisce
    final wiz = wizards[wizIndex];
    int maxSlots = wiz.isSpirit ? 1 : (wiz.savedDice.isNotEmpty ? 4 : 3);
    int available = maxSlots - wiz.savedDice.length;

    if (wiz.selectedDiceForRoll.contains(color)) {
      wiz.selectedDiceForRoll.remove(color);
    } else if (wiz.selectedDiceForRoll.length < available) {
      wiz.selectedDiceForRoll.add(color);
    }
    notifyListeners();
  }

  void rollDice(int wizIndex) {
    if (wizIndex != activeWizardIndex) return;
    final wiz = wizards[wizIndex];
    if (wiz.selectedDiceForRoll.isEmpty) return;

    wiz.currentRoll = wiz.selectedDiceForRoll.map((c) => _rollDirtyDie(c)).toList();
    wiz.selectedDiceForRoll.clear();
    addLog("INFO", "${wiz.className} ha lanciato i dadi.");
    notifyListeners();
  }

  // --- GESTIONE STAMINA E TURNO ---
  
  // METODO MANCANTE: Gestisce il passaggio tra i giocatori
  void endPlayerTurn() {
    if (wizards.isEmpty) return;
    
    addLog("INFO", "⌛ ${wizards[activeWizardIndex].className} termina il turno.");

    if (activeWizardIndex >= wizards.length - 1) {
      // Se era l'ultimo giocatore, resetta il round globale
      activeWizardIndex = 0;
      resetTurn();
    } else {
      // Passa al prossimo giocatore
      activeWizardIndex++;
      addLog("INFO", "▶️ Tocca a ${wizards[activeWizardIndex].className}.");
    }
    notifyListeners();
  }

  void resetTurn() {
    // Risoluzione status Boss
    if ((monsterStatuses['incendiato'] ?? 0) > 0) {
      monsterHp -= monsterStatuses['incendiato']!;
      monsterStatuses['incendiato'] = monsterStatuses['incendiato']! - 1;
    }

    // Ripristino globale Stamina per il nuovo Round
    for (var wiz in wizards) {
      wiz.stamina = wiz.isSpirit ? 1 : 2; //
      wiz.currentRoll = [];
    }
    addLog("INFO", "🔄 Nuovo Round iniziato.");
    notifyListeners();
  }

  void saveDie(int wizIndex, int dieIndex) {
    if (wizIndex != activeWizardIndex) return;
    final wiz = wizards[wizIndex];
    if (wiz.stamina < 1) return;

    wiz.savedDice.add(wiz.currentRoll.removeAt(dieIndex));
    wiz.stamina -= 1; //
    notifyListeners();
  }

  // --- COMBATTIMENTO ---
  bool canWizardCast(int wizIndex, Spell spell) {
    final wiz = wizards[wizIndex];
    if (wiz.isSpirit) return false;
    return ManaEngine.canAfford([...wiz.currentRoll, ...wiz.savedDice], spell.cost);
  }

  void castSpell(Spell spell, int wizIndex) {
    if (wizIndex != activeWizardIndex) return;
    final wiz = wizards[wizIndex];
    if (!canWizardCast(wizIndex, spell)) return;

    _transferManaToOverlord(wiz, spell.cost);
    addLog("INFO", "🔮 ${wiz.className} lancia ${spell.name}.");

    for (var eff in spell.effects) { _resolveEffect(eff, wizIndex); }
    notifyListeners();
  }

  void _transferManaToOverlord(Wizard wiz, Map<String, int> cost) {
    cost.forEach((color, amount) {
      if (color == 'ANY') return;
      for (int i = 0; i < amount; i++) {
        String die;
        if (wiz.currentRoll.contains(color)) {
          die = color; wiz.currentRoll.remove(color);
        } else if (wiz.savedDice.contains(color)) {
          die = color; wiz.savedDice.remove(color);
        } else {
          die = 'K'; 
          if (!wiz.currentRoll.remove('K')) wiz.savedDice.remove('K');
        }
        overlordManaPool[die] = (overlordManaPool[die] ?? 0) + 1; //
      }
    });
  }

  void _resolveEffect(Map<String, dynamic> eff, int wizIndex) {
    final int val = ((eff['value'] ?? 0) as num).toInt();
    if (eff['type'] == 'damage') {
      int d = CombatEngine.calculateDamage(val, monsterDefense);
      monsterHp -= d;
      addLog("DMG", "Danno: -$d HP.");
    }
    if (monsterHp < 0) monsterHp = 0;
  }

  void addLog(String type, String msg) {
    logs.insert(0, {"type": type, "msg": msg});
    if (logs.length > 25) logs.removeLast();
    notifyListeners();
  }
}