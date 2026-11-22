import 'package:flutter_test/flutter_test.dart';
import 'package:oldwest/models/product.dart';
import 'package:oldwest/state/cart_controller.dart';

void main() {
  const burger = Product(id: 1, name: 'X-Brasa', priceCents: 2590);
  late CartController cart;

  setUp(() => cart = CartController());
  tearDown(() => cart.dispose());

  test('adiciona itens e calcula quantidade e subtotal em centavos', () {
    cart.add(burger);
    cart.add(burger);

    expect(cart.itemCount, 2);
    expect(cart.subtotalCents, 5180);
    expect(cart.lines.single.quantity, 2);
  });

  test('decrementa e remove o produto quando chega a zero', () {
    cart.add(burger);
    cart.add(burger);
    cart.decrement(burger);
    expect(cart.itemCount, 1);

    cart.decrement(burger);
    expect(cart.isEmpty, isTrue);
    expect(cart.subtotalCents, 0);
  });

  test('limpa todos os itens', () {
    cart.add(burger);
    cart.clear();
    expect(cart.isEmpty, isTrue);
  });
}
