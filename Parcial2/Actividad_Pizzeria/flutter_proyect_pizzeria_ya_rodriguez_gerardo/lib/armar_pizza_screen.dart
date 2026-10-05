import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'carrito_model.dart';
import 'models.dart';
import 'selector_nivel.dart';
import 'carrito_screen.dart';


class ArmarPizzaScreen extends StatefulWidget {
  const ArmarPizzaScreen({super.key, this.inicial, this.indice});
  final PizzaPersonalizada? inicial;
  final int? indice;

  @override
  State<ArmarPizzaScreen> createState() => _ArmarPizzaScreenState();
}

class _ArmarPizzaScreenState extends State<ArmarPizzaScreen> {
  static const rojo = Color(0xFFE64040);
  static const titulos = [
    'Estilo',
    'Tamaño',
    'Masa',
    'Queso',
    'Ingredientes',
    'Resumen'
  ];

  int paso = 0;
  late Estilo estilo;
  late Opcion tamano, masa, queso;
  late Map<String, Nivel> sel;

  @override
  void initState() {
    super.initState();
    _cargar(widget.inicial);
  }

  void _cargar(PizzaPersonalizada? p) {
    estilo = p?.estilo ?? estilos.first;
    tamano = p?.tamano ?? tamanos[1];
    masa = p?.masa ?? masas[0];
    queso = p?.queso ?? quesos[0];
    sel = p != null ? Map.of(p.ingredientes) : _porDefecto();
  }

  Map<String, Nivel> _porDefecto() =>
      {for (final n in estilo.ingredientes) n: Nivel.normal};

  PizzaPersonalizada get actual => PizzaPersonalizada(
    estilo: estilo,
    tamano: tamano,
    masa: masa,
    queso: queso,
    ingredientes: Map.of(sel),
  );

  void _avanzarAuto() {
    final pasoOrigen = paso;
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted && paso == pasoOrigen && paso < titulos.length - 1) {
        setState(() => paso++);
      }
    });
  }

  String _precio(double p) =>
      p == 0 ? 'Incluido' : '${p > 0 ? '+' : '-'}\$${p.abs().toInt()}';

  // ---------- Finalizar ----------

  void _reiniciar() => setState(() {
    _cargar(null);
    paso = 0;
  });

  void _abrirCarrito() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CarritoScreen()),
    );
  }

  void _finalizar() {
    final carrito = context.read<CarritoModel>();

    if (widget.indice != null) {
      carrito.reemplazar(widget.indice!, actual);
      Navigator.pop(context);
      return;
    }

    final pizza = actual;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar al carrito'),
        content: const Text('¿Deseas agregar otra pizza o realizar el pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              carrito.agregar(pizza);
              _reiniciar();
            },
            child: const Text('Otra pizza'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              carrito.agregar(pizza);
              _reiniciar();
              _abrirCarrito();
            },
            child: const Text('Realizar pedido'),
          ),
        ],
      ),
    );
  }

  // ---------- Componentes ----------

  Widget _tarjeta(
      {required bool activo,
        required VoidCallback onTap,
        required Widget child}) {
    return Card(
      color: activo ? const Color(0xFFFCE9E9) : Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: activo ? rojo : Colors.black12, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(14), child: child),
      ),
    );
  }

  Widget _listaOpciones(
      List<Opcion> ops, Opcion elegida, ValueChanged<Opcion> alElegir) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final o in ops)
          _tarjeta(
            activo: o == elegida,
            onTap: () {
              setState(() => alElegir(o));
              _avanzarAuto();
            },
            child: Row(children: [
              Expanded(
                  child: Text(o.nombre, style: const TextStyle(fontSize: 16))),
              Text(_precio(o.precio),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
          ),
      ],
    );
  }

  Widget _pasoEstilo() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final e in estilos)
          _tarjeta(
            activo: e == estilo,
            onTap: () {
              setState(() {
                estilo = e;
                sel = _porDefecto();
              });
              _avanzarAuto();
            },
            child: Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.nombre,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      e.ingredientes.isEmpty
                          ? 'Sin ingredientes por defecto'
                          : e.ingredientes.join(', '),
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Text('\$${e.precio.toInt()}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
          ),
      ],
    );
  }

  void _abrirAgregar() {
    final buscador = TextEditingController();
    final elegidos = <String>{}; // Selección pendiente, aún no aplicada.

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
        builder: (_) => PopScope(
          canPop: false,
          child: StatefulBuilder(builder: (ctx, setSheet) {
        final q = buscador.text.toLowerCase();
        // Solo se muestran los ingredientes que aún no están en la pizza.
        final lista = catalogoOrdenado
            .where((i) =>
        !sel.containsKey(i.nombre) &&
            i.nombre.toLowerCase().contains(q))
            .toList();

        return Padding(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: SizedBox(
            height: 420,
            child: Column(children: [
              TextField(
                controller: buscador,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Buscar ingrediente'),
                onChanged: (_) => setSheet(() {}),
              ),
              Expanded(
                child: lista.isEmpty
                    ? const Center(
                    child: Text('No hay ingredientes disponibles.'))
                    : ListView(children: [
                  for (final i in lista)
                    CheckboxListTile(
                      activeColor: rojo,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(i.nombre),
                      subtitle: Text(
                          estilo.ingredientes.contains(i.nombre)
                              ? 'Incluido en esta pizza'
                              : '+\$${i.extra.toInt()}'),
                      value: elegidos.contains(i.nombre),
                      onChanged: (v) => setSheet(() {
                        if (v == true) {
                          elegidos.add(i.nombre);
                        } else {
                          elegidos.remove(i.nombre);
                        }
                      }),
                    ),
                ]),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: elegidos.isEmpty
                        ? null
                        : () {
                      setState(() {
                        for (final nombre in elegidos) {
                          sel[nombre] = Nivel.normal;
                        }
                      });
                      Navigator.pop(ctx);
                    },
                    child: Text(elegidos.isEmpty
                        ? 'Agregar'
                        : 'Agregar (${elegidos.length})'),
                  ),
                ),
              ]),
            ]),
          ),
        );
      })),
    ).whenComplete(buscador.dispose);
  }

  Widget _pasoIngredientes() {
    final pizza = actual;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (sel.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No hay ingredientes seleccionados.'),
          ),
        for (final e in (sel.entries.toList()
          ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()))))
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.key, style: const TextStyle(fontSize: 16)),
                  if (pizza.costoDe(e.key, e.value) > 0)
                    Text('+\$${pizza.costoDe(e.key, e.value).toInt()}',
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 12)),
                ],
              ),
            ),
            SelectorNivel(
                nivel: e.value,
                onChanged: (n) => setState(() => sel[e.key] = n)),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => setState(() => sel.remove(e.key)),
            ),
          ]),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _abrirAgregar,
          icon: const Icon(Icons.add),
          label: const Text('Agregar ingrediente'),
        ),
      ],
    );
  }

  Widget _fila(String etiqueta, String valor) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
          width: 100,
          child: Text(etiqueta,
              style: const TextStyle(color: Colors.black54))),
      Expanded(
          child: Text(valor,
              style: const TextStyle(fontWeight: FontWeight.w600))),
    ]),
  );

  Widget _pasoResumen() {
    final p = actual;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _fila('Estilo', p.estilo.nombre),
              _fila('Tamaño', p.tamano.nombre),
              _fila('Masa', p.masa.nombre),
              _fila('Queso', p.queso.nombre),
              _fila('Ingredientes', p.ingredientesTexto),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _contenido() {
    switch (paso) {
      case 0:
        return _pasoEstilo();
      case 1:
        return _listaOpciones(tamanos, tamano, (o) => tamano = o);
      case 2:
        return _listaOpciones(masas, masa, (o) => masa = o);
      case 3:
        return _listaOpciones(quesos, queso, (o) => queso = o);
      case 4:
        return _pasoIngredientes();
      default:
        return _pasoResumen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ultimo = paso == titulos.length - 1;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.indice != null ? 'Editar pizza' : 'Arma tu pizza'),
        actions: widget.indice != null
            ? null
            : [
          Consumer<CarritoModel>(
            builder: (_, carrito, __) => IconButton(
              tooltip: 'Ver carrito',
              onPressed: _abrirCarrito,
              icon: Badge(
                isLabelVisible: carrito.pizzas.isNotEmpty,
                label: Text('${carrito.pizzas.length}'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
              value: (paso + 1) / titulos.length,
              color: rojo,
              backgroundColor: Colors.black12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Paso ${paso + 1} de ${titulos.length}: ${titulos[paso]}',
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(child: _contenido()),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  const Text('Total de la pizza',
                      style: TextStyle(fontSize: 16)),
                  const Spacer(),
                  Text('\$${actual.precio.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: rojo)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: paso > 0 ? () => setState(() => paso--) : null,
                      child: const Text('Atrás'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed:
                      ultimo ? _finalizar : () => setState(() => paso++),
                      child: Text(ultimo
                          ? (widget.indice != null
                          ? 'Guardar cambios'
                          : 'Agregar al carrito')
                          : 'Siguiente'),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
