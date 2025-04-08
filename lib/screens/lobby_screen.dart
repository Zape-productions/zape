import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_screen.dart';
import 'store_screen.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  int coins = 0;
  int highScore = 0;

  @override
  void initState() {
    super.initState();
    loadPlayerData();
  }

  Future<void> loadPlayerData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      coins = prefs.getInt('coins') ?? 0;
      highScore = prefs.getInt('high_score') ?? 0;
    });
  }

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'ZepiBoom',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Coins: $coins',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                    ),
                  ),
                  const Text(
                    ' 🪙',
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'High Score: $highScore',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const GameScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(fontSize: 24),
                ),
                child: const Text('Start Game'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const StoreScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(fontSize: 24),
                ),
                child: Text(
                  'Store',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [Colors.yellow, Colors.orange],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                    fontFamily: 'MotionControl',
                    shadows: [
                      Shadow(
                        blurRadius: 5,
                        color: Colors.orange,
                        offset: const Offset(2, 2),
                      ),
                      Shadow(
                        blurRadius: 5,
                        color: Colors.orange,
                        offset: const Offset(-2, -2),
                      ),
                      Shadow(
                        blurRadius: 5,
                        color: Colors.orange,
                        offset: const Offset(2, -2),
                      ),
                      Shadow(
                        blurRadius: 5,
                        color: Colors.orange,
                        offset: const Offset(-2, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 