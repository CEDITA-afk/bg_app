import 'dart:math';
import 'spell.dart';

class Wizard {
  final String className;
  final String jsonPath;

  int hp = 12;
  final int maxHp = 12;
  
  // Energia: parte da 2 e non ha più un tetto visuale (es. 2/2)
  int stamina = 2; 

  int actions = 2;
  final int maxActions = 2;

  bool hasRolledThisTurn = false;
  bool get isSpirit => hp <= 0;

  List<String> currentRoll = [];        
  List<String> savedDice = [];         
  List<String> selectedDiceForRoll = []; 

  List<Spell> spells = [];
  Point<int> position = const Point(0, 0);

  Wizard({required this.className, required this.jsonPath});

  // Un eroe vivo lancia sempre 3 dadi (che si aggiungono a quelli salvati)
  int get diceToRollLimit => isSpirit ? 1 : 3;
}