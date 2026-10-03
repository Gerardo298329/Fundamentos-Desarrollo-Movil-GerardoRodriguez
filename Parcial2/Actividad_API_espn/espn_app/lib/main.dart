import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESPN Scoreboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const ScoreboardPage(),
    );
  }
}

// ---------- Modelo ----------
class Game {
  final String name;
  final String status;
  final String date;
  final String homeName;
  final String homeLogo;
  final String homeScore;
  final String awayName;
  final String awayLogo;
  final String awayScore;

  Game({
    required this.name,
    required this.status,
    required this.date,
    required this.homeName,
    required this.homeLogo,
    required this.homeScore,
    required this.awayName,
    required this.awayLogo,
    required this.awayScore,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    final competition = json['competitions'][0];
    final competitors = competition['competitors'] as List;
    final home = competitors.firstWhere((c) => c['homeAway'] == 'home');
    final away = competitors.firstWhere((c) => c['homeAway'] == 'away');

    return Game(
      name: json['shortName'] ?? '',
      status: json['status']?['type']?['detail'] ?? '',
      date: json['date'] ?? '',
      homeName: home['team']['displayName'] ?? '',
      homeLogo: home['team']['logo'] ?? '',
      homeScore: home['score']?.toString() ?? '-',
      awayName: away['team']['displayName'] ?? '',
      awayLogo: away['team']['logo'] ?? '',
      awayScore: away['score']?.toString() ?? '-',
    );
  }
}

const Map<String, String> leagues = {
  'Liga MX': 'soccer/mex.1',
  'MLS': 'soccer/usa.1',
  'Premier League': 'soccer/eng.1',
  'NFL': 'football/nfl',
};



String formatDate(String iso) {
  final d = DateTime.tryParse(iso)?.toLocal();
  if (d == null) return '';
  const days = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
  const months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
  ];
  final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final min = d.minute.toString().padLeft(2, '0');
  final ampm = d.hour < 12 ? 'AM' : 'PM';
  return '${days[d.weekday - 1]} ${d.day} ${months[d.month - 1]} · $h12:$min $ampm';
}

String buildUrl(String path, [DateTime? date]) {
  final base =
      'https://site.api.espn.com/apis/site/v2/sports/$path/scoreboard';
  if (date == null) return base; // sin fecha = día/jornada actual

  final d = '${date.year}'
      '${date.month.toString().padLeft(2, '0')}'
      '${date.day.toString().padLeft(2, '0')}';
  return '$base?dates=$d';
}

Future<List<Game>> fetchGames(String path, [DateTime? date]) async {
  final response = await http
      .get(Uri.parse(buildUrl(path, date)))
      .timeout(const Duration(seconds: 15));

  if (response.statusCode != 200) {
    throw Exception('Error del servidor: ${response.statusCode}');
  }

  final data = jsonDecode(response.body);
  final events = data['events'] as List;
  return events.map((e) => Game.fromJson(e)).toList();
}

// Texto corto para mostrar el día seleccionado
String dayLabel(DateTime d) {
  const days = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
  const months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
  ];
  final now = DateTime.now();
  final isToday =
      d.year == now.year && d.month == now.month && d.day == now.day;
  final text = '${days[d.weekday - 1]} ${d.day} ${months[d.month - 1]}';
  return isToday ? 'Hoy · $text' : text;
}

// ---------- Pantalla ----------
class ScoreboardPage extends StatefulWidget {
  const ScoreboardPage({super.key});

  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  String _league = 'Liga MX';
  DateTime _date = DateTime.now();
  late Future<List<Game>> _games;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _games = fetchGames(leagues[_league]!, _date);
  }

  void _load() {
    setState(() {
      _games = fetchGames(leagues[_league]!, _date);
    });
  }

  void _changeLeague(String name) {
    _league = name;
    _query = '';
    _load();
  }

  void _shiftDay(int days) {
    _date = _date.add(Duration(days: days));
    _load();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      _date = picked;
      _load();
    }
  }

  List<Game> _filter(List<Game> games) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return games;
    return games.where((g) {
      return g.homeName.toLowerCase().contains(q) ||
          g.awayName.toLowerCase().contains(q) ||
          g.status.toLowerCase().contains(q);
    }).toList();
  }

  // Caja con fondo, esquinas redondeadas y sombra para resaltar botones
  Widget _actionBox({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_league),
        actions: [
          _actionBox(
            child: PopupMenuButton<String>(
              tooltip: 'Cambiar liga',
              onSelected: _changeLeague,
              itemBuilder: (_) => leagues.keys
                  .map((k) => PopupMenuItem(value: k, child: Text(k)))
                  .toList(),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Cambiar liga'),
                    SizedBox(width: 4),
                    Icon(Icons.sports),
                  ],
                ),
              ),
            ),
          ),
          _actionBox(
            child: IconButton(
              tooltip: 'Recargar',
              onPressed: _load,
              icon: const Icon(Icons.refresh),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ----- Búsqueda -----
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              key: ValueKey(_league),
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Buscar equipo',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          // ----- Título + selector de fecha -----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text('Partidos',
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Día anterior',
                  onPressed: () => _shiftDay(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                TextButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(dayLabel(_date)),
                ),
                IconButton(
                  tooltip: 'Día siguiente',
                  onPressed: () => _shiftDay(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          // ----- Lista -----
          Expanded(
            child: FutureBuilder<List<Game>>(
              future: _games,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 48),
                          const SizedBox(height: 12),
                          Text(
                              'No se pudo cargar $_league.\n'
                                  'Prueba otra liga o fecha.\n\n'
                                  '${snapshot.error}',
                              textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                              onPressed: _load,
                              child: const Text('Reintentar')),
                        ],
                      ),
                    ),
                  );
                }

                final games = _filter(snapshot.data!);
                if (games.isEmpty) {
                  return const Center(
                      child: Text('No hay partidos en este día'));
                }
                return RefreshIndicator(
                  onRefresh: () async => _load(),
                  child: ListView.builder(
                    itemCount: games.length,
                    itemBuilder: (context, i) => GameCard(game: games[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
// ---------- Tarjeta de partido ----------
class GameCard extends StatelessWidget {
  final Game game;
  const GameCard({super.key, required this.game});

  Widget _team(String logo, String name) {
    return Expanded(
      child: Column(
        children: [
          logo.isNotEmpty
              ? Image.network(logo, height: 48,
              errorBuilder: (_, __, ___) => const Icon(Icons.sports))
              : const Icon(Icons.sports),
          const SizedBox(height: 4),
          Text(name, textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(formatDate(game.date),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(game.status, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              children: [
                _team(game.awayLogo, game.awayName),
                Text('${game.awayScore} - ${game.homeScore}',
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold)),
                _team(game.homeLogo, game.homeName),
              ],
            ),
          ],
        ),
      ),
    );
  }
}