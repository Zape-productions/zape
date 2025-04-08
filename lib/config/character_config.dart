import 'package:flutter/material.dart';

class Character {
  final String name;
  final String imagePath;
  final String description;
  final List<String> hitEffects;
  final double damage;
  final String type;

  const Character({
    required this.name,
    required this.imagePath,
    required this.description,
    required this.hitEffects,
    required this.damage,
    required this.type,
  });

  static const Map<String, Character> characters = {
    'default': Character(
      name: 'Stickman',
      imagePath: 'assets/characters/default/character.png',
      description: 'Classic fighter with punch and kick attacks',
      hitEffects: [
        'assets/characters/default/images/hit_effect.png',
        'assets/characters/default/images/hit_effect2.png',
      ],
      damage: 1.0,
      type: 'default',
    ),
    'samurai': Character(
      name: 'Samurai',
      imagePath: 'assets/characters/samurai/character.png',
      description: 'Master swordsman with powerful sword strikes',
      hitEffects: [
        'assets/characters/samurai/effects/sword1.png',
        'assets/characters/samurai/effects/sword2.png',
        'assets/characters/samurai/effects/sword3.png',
        'assets/characters/samurai/effects/sword4.png',
        'assets/characters/samurai/effects/sword5.png',
        'assets/characters/samurai/effects/sword6.png',
      ],
      damage: 1.0,
      type: 'samurai',
    ),
  };

  static Character getCharacter(String type) {
    return characters[type] ?? characters['default']!;
  }
} 