import 'package:flutter/material.dart';
import 'game_screen.dart';

class CharacterSelectScreen extends StatefulWidget {
  const CharacterSelectScreen({super.key});

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen> {
  String selectedCharacter = 'default';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple[900]!, Colors.purple[600]!],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Select Character',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'MotionControl',
                    ),
                  ),
                  const SizedBox(height: 30),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    padding: const EdgeInsets.all(20),
                    childAspectRatio: 0.8,
                    children: [
                      _buildCharacterCard(
                        'Stickman',
                        'assets/characters/default/character.png',
                        'default',
                        'Classic fighter with punch and kick attacks',
                      ),
                      _buildCharacterCard(
                        'Samurai',
                        'assets/characters/samurai/character.png',
                        'samurai',
                        'Master swordsman with powerful sword strikes',
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => GameScreen(characterType: selectedCharacter),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      backgroundColor: Colors.purple[800],
                    ),
                    child: const Text(
                      'Start Game',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'MotionControl',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterCard(String name, String imagePath, String characterType, String description) {
    final isSelected = selectedCharacter == characterType;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCharacter = characterType;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple[800] : Colors.purple[700],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.yellow : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 80,
              width: 80,
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'MotionControl',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 