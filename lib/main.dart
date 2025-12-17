import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TipPage(),
    );
  }
}

class TipPage extends StatefulWidget {
  const TipPage({super.key});

  @override
  State<TipPage> createState() => _TipPageState();
}

class _TipPageState extends State<TipPage> {
  final tips = [
    '人の体の水分量は約60%',
    'バナナは実はベリーの一種',
    'カメは甲羅から出られない',
  ];

  int _index = 0;

  @override
  void initState() {
    super.initState();
    _checkDate();
  }

  Future<void> _checkDate() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = prefs.getString('lastDate');

    if (lastDate != today) {
      _index = DateTime.now().day % tips.length;
      await prefs.setString('lastDate', today);
      await prefs.setInt('tipIndex', _index);
    } else {
      _index = prefs.getInt('tipIndex') ?? 0;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('今日の豆知識')),
      body: Center(
        child: Text(
          tips[_index],
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}