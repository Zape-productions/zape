import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../config/character_config.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameScreen extends StatefulWidget {
  final String characterType;
  final int stage;
  final int subStage;
  final double hp;

  const GameScreen({
    super.key,
    this.characterType = 'default',
    this.stage = 1,
    this.subStage = 1,
    this.hp = 100.0,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Game state
  late Character character;
  late double hp;
  late double maxHp;
  int score = 0;
  int timeLeft = 100;
  int coins = 0;
  int nextCoinCombo = 3 + math.Random().nextInt(3); // 3, 4, or 5
  int comboCount = 0;
  bool showComboMessage = false;
  bool isVictorySequence = false;
  int attacksRemaining = 0;

  // Audio players
  final AudioPlayer punchSound = AudioPlayer();
  final AudioPlayer kickSound = AudioPlayer();
  final AudioPlayer coinSound = AudioPlayer();
  final AudioPlayer victorySound = AudioPlayer();
  final AudioPlayer failedSound = AudioPlayer();
  final AudioPlayer stageClearSound = AudioPlayer();
  final AudioPlayer sword1Sound = AudioPlayer();
  final AudioPlayer sword2Sound = AudioPlayer();

  // Effects
  List<HitEffect> hitEffects = [];
  List<CoinEffect> coinEffects = [];
  Timer? gameTimer;

  // Add new state variable for combo finisher text
  bool showComboFinisher = false;

  // Add new state variable for target shake
  double targetShakeOffset = 0.0;

  // Add new state variable for combo message position
  Offset comboMessagePosition = Offset.zero;

  // Add method to calculate stage HP
  double getStageHp(int stage, int subStage) {
    if (stage == 1) {
      switch (subStage) {
        case 1:
          return 60.0;
        case 2:
          return 100.0;
        case 3:
          return 125.0;
        case 4:
          return 150.0;
        case 5:
          return 200.0;
        default:
          return 60.0;
      }
    } else if (stage == 2) {
      switch (subStage) {
        case 1:
          return 110.0; // 60 + 50
        case 2:
          return 150.0; // 100 + 50
        case 3:
          return 175.0; // 125 + 50
        case 4:
          return 200.0; // 150 + 50
        case 5:
          return 250.0; // 200 + 50
        default:
          return 110.0;
      }
    }
    // For future stages, we can add more cases here
    return 60.0;
  }

  @override
  void initState() {
    super.initState();
    character = Character.getCharacter(widget.characterType);
    maxHp = getStageHp(widget.stage, widget.subStage);
    hp = maxHp;
    loadSounds();
    startGameTimer();
    loadCoins();
    // Reset score and coins for this stage
    score = 0;
    coins = 0;
  }

  Future<void> loadSounds() async {
    try {
      await punchSound.setSource(AssetSource('sounds/punch.wav'));
      await kickSound.setSource(AssetSource('sounds/kick.wav'));
      await coinSound.setSource(AssetSource('sounds/coin.wav'));
      await victorySound.setSource(AssetSource('sounds/victory_sound.wav'));
      await failedSound.setSource(AssetSource('sounds/failed.wav'));
      await stageClearSound.setSource(AssetSource('sounds/stageclear.wav'));
      await sword1Sound.setSource(AssetSource('sounds/sword.wav'));
      await sword2Sound.setSource(AssetSource('sounds/sword1.wav'));
    } catch (e) {
      debugPrint('Error loading sounds: $e');
    }
  }

  Future<void> loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Don't set coins here, just load the saved total
      final savedCoins = prefs.getInt('coins') ?? 0;
      // We'll use this for saving later, but not for display
    });
  }

  Future<void> saveCoins() async {
    final prefs = await SharedPreferences.getInstance();
    final currentSavedCoins = prefs.getInt('coins') ?? 0;
    await prefs.setInt('coins', currentSavedCoins + score); // Add stage score to saved coins
  }

  void startGameTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (timeLeft > 0) {
            timeLeft--;
          } else {
            timer.cancel();
            showFailure();
          }
        });
      }
    });
  }

  void attack(String type, Offset position) {
    // Don't allow attacks during victory sequence
    if (isVictorySequence) return;

    // Check if HP is at or below 20%
    if (hp <= maxHp * 0.2 && !isVictorySequence) {
      startVictorySequence();
      return;
    }

    // Add target shake effect
    setState(() {
      // Random shake between -20 and 20 pixels
      targetShakeOffset = (math.Random().nextDouble() - 0.5) * 40;
    });

    // Reset shake after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          targetShakeOffset = 0;
        });
      }
    });

    // Clear all existing hit effects before adding new ones
    setState(() {
      hitEffects.clear();
      showComboMessage = false;
      // Set random position for combo message
      comboMessagePosition = Offset(
        math.Random().nextDouble() * (MediaQuery.of(context).size.width - 200),
        math.Random().nextDouble() * (MediaQuery.of(context).size.height - 100),
      );
    });

    // Play sound based on character type and click type
    if (character.type == 'samurai') {
      if (type == 'punch') {  // Left click
        sword1Sound.stop();
        sword1Sound.seek(Duration.zero);
        sword1Sound.resume();
      } else {  // Right click
        sword2Sound.stop();
        sword2Sound.seek(Duration.zero);
        sword2Sound.resume();
      }
    } else {
      // Original punch/kick sounds for other characters
      if (type == 'punch') {
        punchSound.stop();
        punchSound.seek(Duration.zero);
        punchSound.resume();
      } else {
        kickSound.stop();
        kickSound.seek(Duration.zero);
        kickSound.resume();
      }
    }

    // Add hit effect
    addHitEffect(position);

    // Add vibration for each attack
    HapticFeedback.mediumImpact();

    setState(() {
      hp -= character.damage;
      comboCount++;
      showComboMessage = true;

      // Spawn coin every 3~5 attacks randomly
      if (comboCount >= nextCoinCombo) {
        spawnCoin(position);
        nextCoinCombo = comboCount + (3 + math.Random().nextInt(3)); // Next coin in 3~5 more hits
      }
    });
  }

  void addHitEffect(Offset position) {
    try {
      final bool showEmoji = math.Random().nextBool();
      
      String? imagePath;
      if (!showEmoji) {
        final randomIndex = math.Random().nextInt(character.hitEffects.length);
        imagePath = character.hitEffects[randomIndex];
      }
      
      final effect = HitEffect(
        position: position,
        imagePath: imagePath,
        effectType: showEmoji ? (math.Random().nextInt(3) + 1) : 0,
        startTime: DateTime.now(),
      );

      setState(() {
        hitEffects.add(effect);
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            hitEffects.remove(effect);
          });
        }
      });
    } catch (e) {
      debugPrint('Error in addHitEffect: $e');
    }
  }

  void spawnCoin(Offset position) {
    // Calculate fixed position on the right side of the target
    final centerX = MediaQuery.of(context).size.width / 2;
    final centerY = MediaQuery.of(context).size.height / 2;
    final fixedPosition = Offset(centerX + 150, centerY); // 150 pixels to the right of center
    
    final effect = CoinEffect(position: fixedPosition, coinValue: 1);
    
    setState(() {
      coinEffects.add(effect);
      coins++;
      score = coins; // Score equals the number of coins collected in this stage
    });

    coinSound.stop();
    coinSound.seek(Duration.zero);
    coinSound.resume();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          coinEffects.remove(effect);
        });
      }
    });
  }

  void startVictorySequence() {
    setState(() {
      isVictorySequence = true;
      attacksRemaining = coins;
      showComboFinisher = true;
    });

    victorySound.stop();
    victorySound.seek(Duration.zero);
    victorySound.resume();

    // Wait for 2 seconds before starting the attack sequence
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      // Start target shaking when attacks begin
      Timer.periodic(const Duration(milliseconds: 30), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          targetShakeOffset = (math.Random().nextDouble() - 0.5) * 40; // ±20 pixels
        });
      });

      // Calculate center position of the target
      final centerX = MediaQuery.of(context).size.width / 2;
      final centerY = MediaQuery.of(context).size.height / 2;
      final centerPosition = Offset(centerX, centerY);

      // Calculate time per attack to distribute them evenly over 3 seconds
      final totalTime = 3000; // 3 seconds in milliseconds
      final timePerAttack = totalTime / coins;
      var currentAttack = 0;

      // Perform all attacks within 3 seconds
      Timer.periodic(Duration(milliseconds: timePerAttack.floor()), (timer) {
        if (!mounted || currentAttack >= coins) {
          timer.cancel();
          // Only show victory if we're still in victory sequence and HP is 0 or below
          if (isVictorySequence && hp <= 0) {
            stageClearSound.stop();
            stageClearSound.seek(Duration.zero);
            stageClearSound.resume();
            showVictory();
          } else if (isVictorySequence) {
            // If HP is not 0, show failure
            failedSound.stop();
            failedSound.seek(Duration.zero);
            failedSound.resume();
            showFailure();
          }
          return;
        }

        // Add some randomness to the hit position around the center
        final randomOffset = Offset(
          (math.Random().nextDouble() - 0.5) * 100,
          (math.Random().nextDouble() - 0.5) * 100,
        );
        
        // Add hit effect at the random position
        addHitEffect(centerPosition + randomOffset);
        
        // Play attack sound based on character type
        if (character.type == 'samurai') {
          if (math.Random().nextBool()) {
            sword1Sound.stop();
            sword1Sound.seek(Duration.zero);
            sword1Sound.resume();
          } else {
            sword2Sound.stop();
            sword2Sound.seek(Duration.zero);
            sword2Sound.resume();
          }
        } else {
          if (math.Random().nextBool()) {
            punchSound.stop();
            punchSound.seek(Duration.zero);
            punchSound.resume();
          } else {
            kickSound.stop();
            kickSound.seek(Duration.zero);
            kickSound.resume();
          }
        }
        
        // Add vibration for each attack
        HapticFeedback.mediumImpact();
        
        setState(() {
          hp -= character.damage;
          currentAttack++;
          comboCount++; // Keep track of combo for animation
          showComboMessage = true;
        });
      });
    });
  }

  void showVictory() async {
    // Save coins only on successful completion
    await saveCoins();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Stage Clear!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $score',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Coins Earned: $score',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Check if we're moving to next main stage
              if (widget.subStage >= 5) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => GameScreen(
                      characterType: widget.characterType,
                      stage: widget.stage + 1,
                      subStage: 1,
                      hp: getStageHp(widget.stage + 1, 1),
                    ),
                  ),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => GameScreen(
                      characterType: widget.characterType,
                      stage: widget.stage,
                      subStage: widget.subStage + 1,
                      hp: getStageHp(widget.stage, widget.subStage + 1),
                    ),
                  ),
                );
              }
            },
            child: const Text(
              'Next Stage',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showFailure() {
    failedSound.stop();
    failedSound.seek(Duration.zero);
    failedSound.resume();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Failed!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $score',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'No coins earned',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => GameScreen(
                    characterType: widget.characterType,
                    stage: widget.stage,
                    subStage: widget.subStage,
                    hp: getStageHp(widget.stage, widget.subStage),
                  ),
                ),
              );
            },
            child: const Text(
              'Try Again',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    punchSound.dispose();
    kickSound.dispose();
    coinSound.dispose();
    victorySound.dispose();
    failedSound.dispose();
    stageClearSound.dispose();
    sword1Sound.dispose();
    sword2Sound.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            // Calculate center position for keyboard attacks
            final centerX = MediaQuery.of(context).size.width / 2;
            final centerY = MediaQuery.of(context).size.height / 2;
            final centerPosition = Offset(centerX, centerY);

            // Check if the key is an alphabet key
            final keyLabel = event.logicalKey.keyLabel;
            if (keyLabel.length == 1 && keyLabel.contains(RegExp(r'[a-zA-Z]'))) {
              // Alternate between punch and kick for each key press
              if (math.Random().nextBool()) {
                attack('punch', centerPosition);
              } else {
                attack('kick', centerPosition);
              }
            }
          }
        },
        child: GestureDetector(
          onSecondaryTapDown: (TapDownDetails details) {
            attack('kick', details.localPosition);
          },
          child: Listener(
            onPointerDown: (PointerDownEvent event) {
              if (event.kind == PointerDeviceKind.mouse) {
                // Mouse input
                if (event.buttons == 1) { // Left click
                  attack('punch', event.localPosition);
                } else if (event.buttons == 2) { // Right click
                  attack('kick', event.localPosition);
                }
              } else {
                // Touch input
                attack('punch', event.localPosition);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.purple[900]!, Colors.purple[600]!],
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    // Game UI
                    Column(
                      children: [
                        // Top bar
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Stage and time
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Stage ${widget.stage}-${widget.subStage}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Time: $timeLeft',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              // Score, coins, and exit button
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Score: $score',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Coins: $coins',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              color: Colors.yellow,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Text(
                                            ' 🪙',
                                            style: TextStyle(fontSize: 24),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 20),
                                  ElevatedButton.icon(
                                    onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[800],
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                    icon: const Icon(Icons.home, color: Colors.white),
                                    label: const Text(
                                      'Start Screen',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // HP bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: hp / maxHp,
                                    minHeight: 20,
                                    backgroundColor: Colors.grey[800],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      hp > maxHp * 0.6 ? Colors.green :
                                      hp > maxHp * 0.3 ? Colors.orange : Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${hp.toInt()}/${maxHp.toInt()}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Target emoji
                        Expanded(
                          child: Center(
                            child: Transform.translate(
                              offset: Offset(targetShakeOffset, 0),
                              child: Text(
                                widget.stage == 1
                                    ? (hp > maxHp * 0.8 ? '😈' :
                                       hp > maxHp * 0.6 ? '👿' :
                                       hp > maxHp * 0.4 ? '😡' :
                                       hp > maxHp * 0.2 ? '🤬' : '💀')
                                    : (hp > maxHp * 0.8 ? '👹' :
                                       hp > maxHp * 0.6 ? '👺' :
                                       hp > maxHp * 0.4 ? '🤡' :
                                       hp > maxHp * 0.2 ? '👻' : '☠️'),
                                style: const TextStyle(fontSize: 200),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Hit effects
                    ...hitEffects.map((effect) {
                      try {
                        if (effect.effectType > 0) {  // Emoji effect with animation
                          final opacity = effect.getOpacity().clamp(0.0, 1.0);
                          final scale = effect.getScale().clamp(0.1, 2.0);
                          
                          return Positioned(
                            left: effect.position.dx - 30,
                            top: effect.position.dy - 30,
                            child: Transform.scale(
                              scale: scale,
                              child: Opacity(
                                opacity: opacity * 0.8,
                                child: Text(
                                  effect.getEmoji(),
                                  style: const TextStyle(fontSize: 50),
                                ),
                              ),
                            ),
                          );
                        } else if (effect.imagePath != null) {  // Hit effect image with fade out
                          final age = DateTime.now().difference(effect.startTime).inMilliseconds;
                          final opacity = age > 400 ? (1.0 - ((age - 400) / 200)).clamp(0.0, 1.0) : 1.0;
                          
                          return Positioned(
                            left: effect.position.dx - 75,
                            top: effect.position.dy - 75,
                            child: Opacity(
                              opacity: opacity,
                              child: Image.asset(
                                effect.imagePath!,
                                width: 150,
                                height: 150,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint('Error loading image: $error');
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      } catch (e) {
                        debugPrint('Error rendering effect: $e');
                        return const SizedBox.shrink();
                      }
                    }),
                    // Coin effects
                    ...coinEffects.map((effect) {
                      try {
                        final opacity = effect.getOpacity();
                        final bounce = effect.getBounce();
                        
                        return Stack(
                          children: [
                            Positioned(
                              left: effect.position.dx,
                              top: effect.initialY + bounce,
                              child: Opacity(
                                opacity: opacity,
                                child: Image.asset(
                                  'assets/images/coin.png',
                                  width: 50,
                                  height: 50,
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint('Error loading coin image: $error');
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              left: effect.position.dx - 20,
                              top: effect.initialY + bounce - 30,
                              child: Opacity(
                                opacity: opacity,
                                child: Text(
                                  'Coin +${effect.coinValue}',
                                  style: const TextStyle(
                                    fontFamily: 'MotionControl',
                                    fontSize: 20,
                                    color: Colors.yellow,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 2,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      } catch (e) {
                        debugPrint('Error rendering coin effect: $e');
                        return const SizedBox.shrink();
                      }
                    }),
                    // Combo message
                    if (showComboMessage)
                      Positioned(
                        left: isVictorySequence 
                            ? MediaQuery.of(context).size.width / 2 - 250
                            : comboMessagePosition.dx,
                        top: isVictorySequence
                            ? MediaQuery.of(context).size.height / 2 - 50
                            : comboMessagePosition.dy,
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 400),
                          tween: Tween(begin: 0.0, end: showComboMessage ? 1.0 : 0.0),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, -30 * value), // Move up 30 pixels
                              child: Transform.scale(
                                scale: 0.5 + 0.7 * value, // Start from 0.5 scale and grow to 1.2
                                child: buildGradientComboText(
                                  'Combo +$comboCount',
                                  32,
                                  160,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    // Combo finisher text
                    if (showComboFinisher)
                      Positioned(
                        left: MediaQuery.of(context).size.width / 2 - 200,
                        top: MediaQuery.of(context).size.height / 2 - 150,
                        child: buildComboFinisherText('Combo Finisher!', 60, 400),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Custom widget for gradient text with outline
  Widget buildGradientComboText(String text, double fontSize, double width) {
    return Stack(
      children: [
        // White outline
        Text(
          text,
          style: TextStyle(
            fontFamily: 'MotionControl',
            fontSize: fontSize,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = Colors.white,
          ),
        ),
        // Gradient text
        Text(
          text,
          style: TextStyle(
            fontFamily: 'MotionControl',
            fontSize: fontSize,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [
                  Colors.orange,
                  Colors.yellow,
                  Colors.white,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(Rect.fromLTWH(0.0, 0.0, width, 0.0)),
            shadows: [
              // Outer glow
              Shadow(
                color: Colors.orange.withOpacity(0.8),
                blurRadius: 12,
                offset: const Offset(0, 0),
              ),
              Shadow(
                color: Colors.orange.withOpacity(0.6),
                blurRadius: 8,
                offset: const Offset(0, 0),
              ),
              // White outline glow
              Shadow(
                color: Colors.white.withOpacity(0.9),
                blurRadius: 4,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Add the buildComboFinisherText method
  Widget buildComboFinisherText(String text, double fontSize, double width) {
    return Stack(
      children: [
        // White outline
        Text(
          text,
          style: TextStyle(
            fontFamily: 'MotionControl',
            fontSize: fontSize,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4
              ..color = Colors.white,
          ),
        ),
        // Gradient text
        Text(
          text,
          style: TextStyle(
            fontFamily: 'MotionControl',
            fontSize: fontSize,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [
                  Colors.blue[300]!,
                  Colors.blue[100]!,
                  Colors.white,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(Rect.fromLTWH(0.0, 0.0, width, 0.0)),
            shadows: [
              // Outer glow
              Shadow(
                color: Colors.blue.withOpacity(0.8),
                blurRadius: 15,
                offset: const Offset(0, 0),
              ),
              Shadow(
                color: Colors.blue.withOpacity(0.6),
                blurRadius: 10,
                offset: const Offset(0, 0),
              ),
              // White outline glow
              Shadow(
                color: Colors.white.withOpacity(0.9),
                blurRadius: 5,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HitEffect {
  final Offset position;
  final String? imagePath;
  final int effectType;  // 0 for no emoji, 1-3 for different emojis
  final DateTime startTime;

  HitEffect({
    required this.position,
    this.imagePath,
    required this.effectType,
    required this.startTime,
  });

  String getEmoji() {
    switch (effectType) {
      case 1:
        return '💢';
      case 2:
        return '💫';
      case 3:
        return '✨';
      default:
        return '';
    }
  }

  double getOpacity() {
    try {
      final age = DateTime.now().difference(startTime).inMilliseconds;
      if (effectType > 0) {  // Emoji animation only
        if (age < 300) {
          return (1.0 - (age / 300)).clamp(0.0, 1.0) * 0.8; // Fade out over 300ms
        }
        return 0.0;
      } else {  // Hit effect image - no animation
        return 1.0;  // Always full opacity
      }
    } catch (e) {
      return 1.0;
    }
  }

  double getScale() {
    try {
      if (effectType > 0) {  // Emoji animation only
        final age = DateTime.now().difference(startTime).inMilliseconds;
        if (age < 300) {
          return 0.1 + (age / 300) * 1.9;  // Grow from 0.1 to 2.0 over 300ms
        }
        return 2.0;
      } else {  // Hit effect image - no animation
        return 1.0;  // No scaling
      }
    } catch (e) {
      return 1.0;
    }
  }
}

class CoinEffect {
  final Offset position;
  final DateTime startTime;
  final double initialY;
  final int coinValue;

  CoinEffect({
    required this.position,
    required this.coinValue,
  }) : startTime = DateTime.now(), initialY = position.dy;

  double getOpacity() {
    final age = DateTime.now().difference(startTime).inMilliseconds;
    if (age < 200) {
      return age / 200; // Fade in
    } else if (age > 400) {
      return (1.0 - ((age - 400) / 200)).clamp(0.0, 1.0); // Fade out
    }
    return 1.0; // Full opacity
  }

  double getBounce() {
    final age = DateTime.now().difference(startTime).inMilliseconds;
    if (age < 400) {
      // Simple upward movement
      return -100 * (age / 400); // Move up 100 pixels over 400ms
    }
    return -100; // Stay at the top position
  }
} 