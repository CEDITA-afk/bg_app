class Spell {
  final String id;
  final String name;
  final String description;
  final Map<String, int> cost;
  final List<dynamic> effects;
  final Kicker? kicker; // Il kicker è opzionale

  Spell({required this.id, required this.name, required this.description, 
         required this.cost, required this.effects, this.kicker});

  factory Spell.fromJson(Map<String, dynamic> json) {
    return Spell(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      cost: Map<String, int>.from(json['cost_main'] ?? json['cost'] ?? {}),
      effects: json['effects_main'] ?? json['effects'] ?? [],
      kicker: json['kicker'] != null ? Kicker.fromJson(json['kicker']) : null,
    );
  }
}

class Kicker {
  final Map<String, int> costAdd;
  final String description;
  final List<dynamic> effectsAdd;

  Kicker({required this.costAdd, required this.description, required this.effectsAdd});

  factory Kicker.fromJson(Map<String, dynamic> json) {
    return Kicker(
      costAdd: Map<String, int>.from(json['cost_add'] ?? {}),
      description: json['description'] ?? '',
      effectsAdd: json['effects_add'] ?? [],
    );
  }
}