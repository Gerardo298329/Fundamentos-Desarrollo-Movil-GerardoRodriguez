import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'armar_pizza_screen.dart';
import 'carrito_model.dart';

/// Resumen del pedido: permite editar, eliminar, agregar, cancelar y confirmar.
class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  static const rojo = Color(0xFFE64040);

  Future<void> _confirmarCancelar(BuildContext context) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar pedido'),
        content: const Text(
            'Se eliminarán todas las pizzas del carrito. ¿Deseas continuar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sí, cancelar')),
        ],
      ),
    );
    if (confirmado == true && context.mounted) {
      context.read<CarritoModel>().vaciar();
      Navigator.pop(context);
    }
  }

  void _realizarPedido(BuildContext context) {
    final carrito = context.read<CarritoModel>();
    final total = carrito.total;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('¡Pedido realizado!'),
        content: Text(
            'Tu pedido por \$${total.toStringAsFixed(0)} fue realizado con éxito.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              carrito.vaciar();
              Navigator.pop(context);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoModel>();
    final pizzas = carrito.pizzas;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Carrito')),
      body: pizzas.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tu carrito está vacío',
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Armar una pizza'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pizzas.length,
              itemBuilder: (_, i) {
                final p = pizzas[i];
                return Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(
                              '${p.estilo.nombre} · ${p.tamano.nombre}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text('\$${p.precio.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ]),
                        const SizedBox(height: 4),
                        Text(
                            'Masa ${p.masa.nombre} · Queso ${p.queso.nombre}',
                            style: const TextStyle(color: Colors.black54)),
                        Text(p.ingredientesTexto,
                            style: const TextStyle(color: Colors.black54)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ArmarPizzaScreen(
                                      inicial: p, indice: i),
                                ),
                              ),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Editar'),
                            ),
                            TextButton.icon(
                              onPressed: () => carrito.eliminar(i),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black12)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    Text(
                        '${pizzas.length} ${pizzas.length == 1 ? 'pizza' : 'pizzas'}',
                        style: const TextStyle(color: Colors.black54)),
                    const Spacer(),
                    const Text('Total  ', style: TextStyle(fontSize: 16)),
                    Text('\$${carrito.total.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: rojo)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Agregar otra'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _confirmarCancelar(context),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => _realizarPedido(context),
                      child: const Text('Realizar pedido'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}