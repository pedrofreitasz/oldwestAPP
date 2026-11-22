import 'package:flutter/foundation.dart';

import '../models/product.dart';

class CartLine {
  const CartLine({required this.product, required this.quantity});
  final Product product;
  final int quantity;
  int get lineTotalCents => product.priceCents * quantity;
}

class CartController extends ChangeNotifier {
  final Map<int, CartLine> _lines = {};

  List<CartLine> get lines => List.unmodifiable(_lines.values);
  int get itemCount => _lines.values.fold(0, (sum, line) => sum + line.quantity);
  int get subtotalCents =>
      _lines.values.fold(0, (sum, line) => sum + line.lineTotalCents);
  bool get isEmpty => _lines.isEmpty;

  void add(Product product) {
    final current = _lines[product.id];
    if (current != null && current.quantity >= 99) return;
    _lines[product.id] = CartLine(
      product: product,
      quantity: (current?.quantity ?? 0) + 1,
    );
    notifyListeners();
  }

  void decrement(Product product) {
    final current = _lines[product.id];
    if (current == null) return;
    if (current.quantity <= 1) {
      _lines.remove(product.id);
    } else {
      _lines[product.id] = CartLine(
        product: product,
        quantity: current.quantity - 1,
      );
    }
    notifyListeners();
  }

  void remove(Product product) {
    _lines.remove(product.id);
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }
}
