class CombatEngine {
  // Gestisce il calcolo del danno considerando la difesa
  static int calculateDamage(int value, int defense, {bool ignoreDef = false}) {
    if (ignoreDef) return value;
    int finalDmg = value - defense;
    return finalDmg > 0 ? finalDmg : 0;
  }

  // Logica per l'effetto detonate_incendiato
  static int resolveDetonation(Map<String, int> statuses, int bonus) {
    int stacks = statuses['incendiato'] ?? 0;
    if (stacks > 0) {
      return stacks + bonus;
    }
    return 0;
  }
}