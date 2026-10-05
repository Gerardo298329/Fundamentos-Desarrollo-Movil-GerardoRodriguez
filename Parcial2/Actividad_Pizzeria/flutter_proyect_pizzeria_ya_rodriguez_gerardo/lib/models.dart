enum Nivel { poco, normal, extra }

extension NivelX on Nivel {
  String get texto => const {
    Nivel.poco: 'Poco',
    Nivel.normal: 'Normal',
    Nivel.extra: 'Extra',
  }[this]!;
}

class Ingrediente {
  final String nombre;
  final double extra; // costo cuando el nivel es Extra
  const Ingrediente(this.nombre, this.extra);
}

class Opcion {
  final String nombre;
  final double precio;
  const Opcion(this.nombre, this.precio);
}

class Estilo {
  final String nombre;
  final double precio;
  final List<String> ingredientes; // por defecto
  const Estilo(this.nombre, this.precio, this.ingredientes);
}

const catalogo = [
  Ingrediente('Jamón', 15),
  Ingrediente('Piña', 15),
  Ingrediente('Pepperoni', 15),
  Ingrediente('Champiñón', 15),
  Ingrediente('Jalapeño', 10),
  Ingrediente('Cebolla', 10),
  Ingrediente('Chorizo', 15),
  Ingrediente('Pimiento', 10),
  Ingrediente('Aceitunas', 12),
  Ingrediente('Tocino', 15),
];
final catalogoOrdenado = [...catalogo]
  ..sort((a, b) =>
      a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));

double precioExtra(String nombre) =>
    catalogo.firstWhere((i) => i.nombre == nombre).extra;

const estilos = [
  Estilo('Hawaiana', 149, ['Jamón', 'Piña']),
  Estilo('Pepperoni', 139, ['Pepperoni']),
  Estilo('Mexicana', 159, ['Champiñón', 'Jalapeño', 'Chorizo']),
  Estilo('Dúo', 169, ['Pepperoni', 'Jamón']),
  Estilo('Arma la tuya', 119, []),
];

const tamanos = [
  Opcion('Chica', -20),
  Opcion('Mediana', 0),
  Opcion('Grande', 30),
];
const masas = [
  Opcion('Tradicional', 0),
  Opcion('Delgada', 0),
  Opcion('Orilla de queso', 25),
];
const quesos = [
  Opcion('Mozzarella', 0),
  Opcion('Doble queso', 20),
  Opcion('Sin queso', -10),
];


/// Configuración completa de una pizza lista para el carrito.
class PizzaPersonalizada {
  final Estilo estilo;
  final Opcion tamano;
  final Opcion masa;
  final Opcion queso;
  final Map<String, Nivel> ingredientes;

  const PizzaPersonalizada({
    required this.estilo,
    required this.tamano,
    required this.masa,
    required this.queso,
    required this.ingredientes,
  });

  /// Costo de un ingrediente según su nivel.
  /// Ingrediente propio de la pizza: solo tiene costo en nivel Extra.
  /// Ingrediente agregado: cuesta su precio, y el doble en nivel Extra.
  double costoDe(String nombre, Nivel nivel) {
    final base = precioExtra(nombre);
    final esPropio = estilo.ingredientes.contains(nombre);
    if (esPropio) return nivel == Nivel.extra ? base : 0;
    return nivel == Nivel.extra ? base * 2 : base;
  }

  double get precio {
    var total = estilo.precio + tamano.precio + masa.precio + queso.precio;
    ingredientes.forEach((nombre, nivel) => total += costoDe(nombre, nivel));
    return total;
  }

  String get ingredientesTexto {
    if (ingredientes.isEmpty) return 'Sin ingredientes';
    final ordenados = ingredientes.entries.toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));
    return ordenados.map((e) => '${e.key} (${e.value.texto})').join(', ');
  }
}