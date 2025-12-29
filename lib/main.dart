import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 初期履歴データ（初回起動時のみ保存）
const initialHistory = [
  '2025-01-01|人の体の水分量は約60%',
  '2025-01-02|バナナは実はベリーの一種',
];

void main() {
  runApp(const MyApp());
}

/// --------------------
/// アプリ本体
/// --------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TipPage(),
    );
  }
}

/// --------------------
/// 今日の話の種ページ
/// --------------------
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

  final openers = [
    '知ってた？実はね…',
    'これちょっと面白いんだけど',
    '雑談ネタなんだけどさ',
  ];

  final followUps = [
    'どんな果物が好き？',
    'こういう話、知ってた？',
    '前から気になってたんだけど',
  ];

  int _index = 0;

  @override
  void initState() {
    super.initState();
    _checkDate();
  }

  /// 日付変更チェック＋保存
  Future<void> _checkDate() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);

    // 初回起動時のみ初期履歴を保存
    if (prefs.getStringList('history') == null) {
      await prefs.setStringList('history', initialHistory);
    }

    final lastDate = prefs.getString('lastDate');

    if (lastDate != today) {
      _index = DateTime.now().day % tips.length;

      await prefs.setString('lastDate', today);
      await prefs.setInt('tipIndex', _index);

      final history = prefs.getStringList('history') ?? [];

      // 同じ日付がなければ追加
      final exists = history.any((e) => e.startsWith('$today|'));
      if (!exists) {
        history.add('$today|${tips[_index]}');
        await prefs.setStringList('history', history);
      }
    } else {
      _index = prefs.getInt('tipIndex') ?? 0;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今日の話の種'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('豆知識'),
                _BodyText(tips[_index]),

                const SizedBox(height: 16),

                const _SectionTitle('話しかけ方'),
                _BodyText(openers[_index % openers.length]),

                const SizedBox(height: 16),

                const _SectionTitle('会話の続け方'),
                _BodyText(followUps[_index % followUps.length]),

                const SizedBox(height: 24),

                const _ActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// --------------------
/// 履歴ページ
/// --------------------
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Future<List<String>> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('history') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('過去の話の種')),
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

/// --------------------
/// UI部品
/// --------------------
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;
  const _BodyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.check),
          label: const Text('使った'),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.favorite_border),
        ),
      ],
    );
  }
}