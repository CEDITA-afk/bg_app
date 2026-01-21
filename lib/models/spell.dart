class Spell {
  final String id;
  final String name;
  final String description;
  final Map<String, int> cost;
  final List<dynamic> effects;
  final Kicker? kicker;

  Spell({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.effects,
    this.kicker,
  });

 factory Spell.fromJson(Map<String, dynamic> json) {
  // Supporta entrambi i formati di chiave per compatibilità
  var costData = json['cost_main'] ?? json['cost'] ?? {};
  var effectsData = json['effects_main'] ?? json['effects'] ?? [];

  return Spell(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    cost: Map<String, int>.from(costData),
    effects: List<dynamic>.from(effectsData),
    kicker: json['kicker'] != null ? Kicker.fromJson(json['kicker']) : null,
  );
 }
}

class Kicker {
  final Map<String, int> costAdd;
  final List<dynamic> effectsAdd;
  final String description;

  Kicker({
    required this.costAdd,
    required this.effectsAdd,
    required this.description,
  });

  factory Kicker.fromJson(Map<String, dynamic> json) {
    return Kicker(
      costAdd: Map<String, int>.from(json['cost_add'] ?? {}),
      effectsAdd: json['effects_add'] ?? [],
      description: json['description'] ?? '',
    );
  }
}