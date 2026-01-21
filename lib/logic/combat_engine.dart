import 'dart:math';

class CombatEngine {
  /// Calcola il danno finale sottraendo la difesa (Armatura)
  /// Se il danno è inferiore alla difesa, il risultato è 0 (non negativo)
  static int calculateDamage(int baseDamage, int defense) {
    // Il danno non può scendere sotto lo zero
    return max(0, baseDamage - defense);
  }

  /// Calcola i danni da status (es. Bruciatura o Tempesta)
  /// Questi danni solitamente ignorano la difesa (Danno Diretto)
  static int calculateStatusDamage(int stacks) {
    return stacks;
  }
  
  /// In futuro qui potremo aggiungere logiche per:
  /// - Critici (se implementati)
  /// - Resistenze elementali specifiche
  /// - Bonus da Posizionamento (Fase 4: Tactical Grid)
}