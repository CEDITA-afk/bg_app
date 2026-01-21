import 'dart:math';

class DiceEngine {
  /// Implementa il sistema "Dirty Dice" (Regolamento 2.1)
  /// Probabilità: 
  /// 1 (16.6%) -> JOLLY (K)
  /// 2-3 (33.3%) -> PURO (Stesso colore del dado)
  /// 4-6 (50%) -> IBRIDO (Uno degli altri 3 colori elementali)
  static String rollDirty(String dieColor) {
    final random = Random();
    int result = random.nextInt(6) + 1; // Lancio 1d6

    if (result == 1) {
      return 'K'; // Jolly/Ombra (Nero)
    } else if (result <= 3) {
      return dieColor; // Risultato Puro
    } else {
      // Risultato Ibrido: sceglie casualmente tra gli altri 3 colori elementali
      List<String> elementalColors = ['R', 'B', 'G', 'Y'];
      elementalColors.remove(dieColor); // Rimuove il colore puro
      return elementalColors[random.nextInt(elementalColors.length)];
    }
  }
}