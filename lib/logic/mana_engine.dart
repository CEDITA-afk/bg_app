class ManaEngine {
  /// Converte una lista di dadi in una mappa di conteggio (Pool)
  static Map<String, int> getPoolFromDice(List<String> dice) {
    Map<String, int> pool = {};
    for (var die in dice) {
      pool[die] = (pool[die] ?? 0) + 1;
    }
    return pool;
  }

  /// Verifica se il pool di dadi copre il costo richiesto (Regolamento 2.1)
  static bool canAfford(List<String> currentDice, Map<String, int> cost) {
    Map<String, int> pool = getPoolFromDice(currentDice);
    int wildcards = pool['K'] ?? 0; // Riserva di Jolly
    pool.remove('K');

    // 1. Verifica e consuma mana per i costi specifici (R, B, G, Y)
    for (var entry in cost.entries) {
      String color = entry.key;
      int amount = entry.value;
      if (color == 'ANY') continue;

      int available = pool[color] ?? 0;
      if (available >= amount) {
        pool[color] = available - amount;
      } else {
        // Se non basta il colore puro, usa i Jolly disponibili
        int needed = amount - available;
        if (wildcards >= needed) {
          pool[color] = 0;
          wildcards -= needed;
        } else {
          return false; // Mana insufficiente anche con i Jolly
        }
      }
    }
    
    // 2. Verifica se i dadi rimanenti (Normali + Jolly) coprono il costo ANY
    if (cost.containsKey('ANY')) {
      int remainingNormalDice = pool.values.fold(0, (sum, count) => sum + count);
      if ((remainingNormalDice + wildcards) < cost['ANY']!) {
        return false;
      }
    }
    
    return true;
  }
}