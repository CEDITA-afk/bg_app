class ManaEngine {
  // Converte la lista di dadi ['R', 'R', 'G'] in una mappa {'R': 2, 'G': 1}
  static Map<String, int> getPoolFromDice(List<String> dice) {
    Map<String, int> pool = {};
    for (var die in dice) {
      pool[die] = (pool[die] ?? 0) + 1;
    }
    return pool;
  }

  // Traduzione fedele di canAfford
  static bool canAfford(List<String> savedDice, Map<String, int> cost) {
    Map<String, int> pool = getPoolFromDice(savedDice);
    
    // 1. Controlla e sottrae i costi specifici
    for (var entry in cost.entries) {
      if (entry.key == 'ANY') continue;
      if ((pool[entry.key] ?? 0) < entry.value) return false;
      pool[entry.key] = pool[entry.key]! - entry.value;
    }
    
    // 2. Controlla se i dadi rimanenti coprono il costo ANY
    if (cost.containsKey('ANY')) {
      int remainingDice = pool.values.fold(0, (sum, count) => sum + count);
      if (remainingDice < cost['ANY']!) return false;
    }
    
    return true;
  }
}