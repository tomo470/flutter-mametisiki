import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const TipPage(),
    );
  }
}

class TipPage extends StatelessWidget {
  const TipPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tips = [
      '人の体の水分量は約60%',
      'バナナは実はベリーの一種',
      'カメは甲羅から出られない',
    ];

    final index = DateTime.now().day % tips.length;

    return Scaffold(
      appBar: AppBar(title: const Text('今日の豆知識')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            tips[index],
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}