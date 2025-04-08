import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lobby_screen.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  int playerCoins = 0;
  List<String> ownedCharacters = [];
  List<String> ownedTargets = [];

  // Store items data
  final List<StoreItem> characters = [
    StoreItem(
      id: 'stickman',
      name: 'Stickman',
      price: 0,
      type: 'character',
      description: 'Basic character with punch and kick animations',
      isUnlocked: true,
    ),
    StoreItem(
      id: 'ninja',
      name: 'Ninja',
      price: 100,
      type: 'character',
      description: 'Fast and agile character with special moves',
      isUnlocked: false,
    ),
    StoreItem(
      id: 'robot',
      name: 'Robot',
      price: 200,
      type: 'character',
      description: 'Mechanical character with powerful attacks',
      isUnlocked: false,
    ),
  ];

  final List<StoreItem> targets = [
    StoreItem(
      id: 'emoji',
      name: 'Emoji Target',
      price: 0,
      type: 'target',
      description: 'Basic emoji target with different expressions',
      isUnlocked: true,
    ),
    StoreItem(
      id: 'punching_bag',
      name: 'Punching Bag',
      price: 50,
      type: 'target',
      description: 'Classic boxing bag with realistic physics',
      isUnlocked: false,
    ),
    StoreItem(
      id: 'stress_ball',
      name: 'Stress Ball',
      price: 75,
      type: 'target',
      description: 'Squishy target that bounces back',
      isUnlocked: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    loadPlayerData();
  }

  Future<void> loadPlayerData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      playerCoins = prefs.getInt('coins') ?? 0;
      ownedCharacters = prefs.getStringList('owned_characters') ?? ['stickman'];
      ownedTargets = prefs.getStringList('owned_targets') ?? ['emoji'];
    });
  }

  Future<void> purchaseItem(StoreItem item) async {
    if (playerCoins >= item.price && !item.isUnlocked) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        playerCoins -= item.price;
        if (item.type == 'character') {
          ownedCharacters.add(item.id);
        } else {
          ownedTargets.add(item.id);
        }
      });
      
      await prefs.setInt('coins', playerCoins);
      await prefs.setStringList('owned_characters', ownedCharacters);
      await prefs.setStringList('owned_targets', ownedTargets);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LobbyScreen()),
            );
          },
        ),
      ),
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
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Coins:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          playerCoins.toString(),
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
                  ],
                ),
              ),
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: 'Characters'),
                          Tab(text: 'Targets'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildStoreList(characters),
                            _buildStoreList(targets),
                          ],
                        ),
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

  Widget _buildStoreList(List<StoreItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isOwned = item.type == 'character'
            ? ownedCharacters.contains(item.id)
            : ownedTargets.contains(item.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: ListTile(
            title: Text(item.name),
            subtitle: Text(item.description),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isOwned)
                  const Text(
                    'Owned',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.price.toString(),
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(' 🪙'),
                    ],
                  ),
              ],
            ),
            onTap: () {
              if (!isOwned && playerCoins >= item.price) {
                purchaseItem(item);
              }
            },
          ),
        );
      },
    );
  }
}

class StoreItem {
  final String id;
  final String name;
  final int price;
  final String type;
  final String description;
  final bool isUnlocked;

  StoreItem({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    required this.description,
    required this.isUnlocked,
  });
} 