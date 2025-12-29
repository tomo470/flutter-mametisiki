import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, String> history = {
  '2025-01-01': '人の体の水分量は約60%',
  '2025-01-02': 'バナナは実はベリーの一種'
};

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

    // 初回起動時にグローバルhistoryをSharedPreferencesに保存
    final existingHistory = prefs.getStringList('history');
    if (existingHistory == null) {
      final historyList = history.entries.map((e) => '${e.key}|${e.value}').toList();
      await prefs.setStringList('history', historyList);
    }

    if (lastDate != today) {
      _index = DateTime.now().day % tips.length;
      await prefs.setString('lastDate', today);
      await prefs.setInt('tipIndex', _index);
      
      final history = prefs.getStringList('history') ?? [];
      history.add('$today|${tips[_index]}');
      await prefs.setStringList('history', history);

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
      floatingActionButton: IconButton(
        icon: const Icon(Icons.history),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoryPage()),
          );
        },
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Future<List<String>> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('history') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('過去の豆知識')),
      body: FutureBuilder<List<String>>(
        future: _loadHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final history = snapshot.data!.reversed.toList();

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final parts = history[index].split('|');
              return ListTile(
                title: Text(parts[1]),
                subtitle: Text(parts[0]),
              );
            },
          );
        },
      ),
    );
  }
}