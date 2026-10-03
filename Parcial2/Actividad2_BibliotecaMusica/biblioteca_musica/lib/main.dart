import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://vosdkohlbblbawnatora.supabase.co',
    anonKey: 'sb_publishable_d0XZBporrQiXGGfJROI3XQ_vnNbfvh6',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mis canciones',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const CancionesPage(),
    );
  }
}

class CancionesPage extends StatefulWidget {
  const CancionesPage({super.key});

  @override
  State<CancionesPage> createState() => _CancionesPageState();
}

class _CancionesPageState extends State<CancionesPage> {
  List<Map<String, dynamic>> canciones = [];
  bool cargando = true;
  bool soloFavoritas = false;
  String busqueda = '';
  String? error;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    try {
      final data = await supabase
          .from('canciones')
          .select()
          .order('titulo', ascending: true);
      setState(() {
        canciones = List<Map<String, dynamic>>.from(data);
        cargando = false;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        cargando = false;
      });
    }
  }

  Future<void> alternarFavorita(Map<String, dynamic> c) async {
    final nuevo = !(c['favorita'] as bool);
    setState(() => c['favorita'] = nuevo); // cambio inmediato en pantalla
    try {
      await supabase
          .from('canciones')
          .update({'favorita': nuevo})
          .eq('id', c['id']);
    } catch (e) {
      setState(() => c['favorita'] = !nuevo);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No se pudo actualizar')));
      }
    }
  }

  String formatoDuracion(int? seg) {
    if (seg == null) return '--:--';
    final s = (seg % 60).toString().padLeft(2, '0');
    return '${seg ~/ 60}:$s';
  }

  List<Map<String, dynamic>> get filtradas {
    return canciones.where((c) {
      if (soloFavoritas && c['favorita'] != true) return false;
      if (busqueda.isEmpty) return true;
      final q = busqueda.toLowerCase();
      return c['titulo'].toString().toLowerCase().contains(q) ||
          c['artista'].toString().toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final lista = filtradas;
    final totalFav = canciones.where((c) => c['favorita'] == true).length;
    final pantalla = MediaQuery.sizeOf(context);
    final ancho = pantalla.width * 0.7;
    final alto = pantalla.height * 0.85;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis canciones',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colores.primaryContainer,
        foregroundColor: colores.onPrimaryContainer,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error: $error', textAlign: TextAlign.center),
              ),
            )
          : Center(
              child: Container(
                width: ancho,
                height: alto,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colores.outlineVariant),
                ),
                child: Column(
                  children: [
                    // Buscador
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: SearchBar(
                        hintText: 'Buscar canción o artista',
                        leading: const Icon(Icons.search),
                        elevation: const WidgetStatePropertyAll(0),
                        onChanged: (v) => setState(() => busqueda = v),
                      ),
                    ),
                    // Filtro y contador
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          FilterChip(
                            label: Text('Favoritas ($totalFav)'),
                            avatar: Icon(
                              Icons.favorite,
                              size: 18,
                              color: soloFavoritas ? null : Colors.red,
                            ),
                            selected: soloFavoritas,
                            onSelected: (v) =>
                                setState(() => soloFavoritas = v),
                          ),
                          const Spacer(),
                          Text(
                            '${lista.length} canciones',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Lista
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: cargar,
                        child: lista.isEmpty
                            ? ListView(
                                children: const [
                                  SizedBox(height: 120),
                                  Center(child: Text('No hay canciones')),
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  0,
                                  12,
                                  16,
                                ),
                                itemCount: lista.length,
                                itemBuilder: (context, i) =>
                                    tarjeta(lista[i], colores),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget tarjeta(Map<String, dynamic> c, ColorScheme colores) {
    final fav = c['favorita'] as bool;
    final inicial = c['titulo'].toString().substring(0, 1).toUpperCase();

    return Card(
      elevation: 0,
      color: colores.surfaceContainerHighest.withOpacity(0.5),
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: colores.primary,
          foregroundColor: colores.onPrimary,
          child: Text(
            inicial,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          c['titulo'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${c['artista']}\n${c['album'] ?? ''} • ${c['anio'] ?? ''} • ${formatoDuracion(c['duracion_seg'])}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: Icon(
            fav ? Icons.favorite : Icons.favorite_border,
            color: fav ? Colors.red : colores.outline,
          ),
          onPressed: () => alternarFavorita(c),
        ),
      ),
    );
  }
}
