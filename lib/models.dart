// lib/models.dart

import 'dart:math';

// Rappresenta i colori del mana
enum ManaColor { R, G, B, Y, W, ANY }

// Modello per le Magie (basato sui tuoi spells_*.json)
class Spell {
  final String name;
  final String description;
  final Map<String, int> cost;
  final List<Map<String, dynamic>> effects;

  Spell({
    required this.name,
    required this.description,
    required this.cost,
    required this.effects,
  });
}

// Modello per il Mago (basato su player.js)
class Wizard {
  final String className;
  int energy = 0;
  int actions = 0;
  final int maxActions = 2;
  List<String> currentRoll = [];
  List<String> savedDice = [];
  bool hasRolled = false;

  Wizard({required this.className});
}