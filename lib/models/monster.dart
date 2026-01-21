import 'dart:math';

class MonsterAbility {
  final String name;
  final Map<String, int> cost;
  final String description;
  final int damage;

  MonsterAbility({required this.name, required this.cost, required this.description, required this.damage});
}

class Monster {
  String name = "EXO-01, Il Guardiano";
  int phase = 1;
  int hp = 30;
  int maxHp = 30;
  int defense = 2;
  Map<String, int> manaPool = {'R': 0, 'B': 0, 'G': 0, 'Y': 0, 'K': 0};

  // Definiamo le abilità dal documento EXO-01 [cite: 15, 19, 24, 29, 36]
  List<MonsterAbility> get abilities => [
    MonsterAbility(name: "Pressa Idraulica", cost: {'ANY': 2}, description: "2 Danni fisici a bersaglio adiacente", damage: 2),
    MonsterAbility(name: "Bobina di Tesla", cost: {'Y': 2}, description: "1 Danno e status Conduttore", damage: 1),
    MonsterAbility(name: "Protocollo: Magnete", cost: {'B': 2, 'R': 1}, description: "Attira eroi e infligge 1 danno", damage: 1),
    MonsterAbility(name: "Sfiato di Vapore", cost: {'R': 2, 'G': 1}, description: "Crea copertura e +2 Armatura", damage: 0),
  ];

  Monster();

  void nextPhase() {
    if (phase == 1) {
      phase = 2;
      name = "EXO-01 (NUCLEO ESPOSTO)";
      hp = 25;
      maxHp = 25;
      defense = 0;
    }
  }

  void addMana(String color, int amount) {
    manaPool[color] = (manaPool[color] ?? 0) + amount;
  }
}