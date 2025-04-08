import 'package:flutter/material.dart';
import 'screens/start_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zepiboom',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'MotionControl',
      ),
      home: const StartScreen(),
    );
  }
}
