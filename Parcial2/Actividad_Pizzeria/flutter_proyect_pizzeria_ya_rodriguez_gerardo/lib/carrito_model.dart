import 'package:flutter/foundation.dart';
import 'models.dart';

/// Estado del carrito de compras, compartido entre pantallas.
class CarritoModel extends ChangeNotifier {
  final List<PizzaPersonalizada> _pizzas = [];

  List<PizzaPersonalizada> get pizzas => List.unmodifiable(_pizzas);

  double get total => _pizzas.fold(0, (suma, p) => suma + p.precio);

  void agregar(PizzaPersonalizada pizza) {
    _pizzas.add(pizza);
    notifyListeners();
  }

  void reemplazar(int indice, PizzaPersonalizada pizza) {
    _pizzas[indice] = pizza;
    notifyListeners();
  }

  void eliminar(int indice) {
    _pizzas.removeAt(indice);
    notifyListeners();
  }

  void vaciar() {
    _pizzas.clear();
    notifyListeners();
  }
}