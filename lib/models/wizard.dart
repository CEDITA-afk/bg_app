import 'spell.dart';

class Wizard {
  final String className;
  final String jsonPath;

  int hp = 12;
  final int maxHp = 12;
  int stamina = 2;
  final int maxStamina = 2;

  bool get isSpirit => hp <= 0;

  List<String> currentRoll = [];
  List<String> savedDice = []; // Accumulo
  List<Spell> spells = [];
  List<String> selectedDiceForRoll = [];

  int get maxRollSlots {
    if (isSpirit) return 1;
    return (savedDice.isNotEmpty) ? 4 : 3;
  }

  Wizard({required this.className, required this.jsonPath});
}