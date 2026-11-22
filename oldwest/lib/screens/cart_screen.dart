import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/api_client.dart';
import '../state/cart_controller.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.api, required this.cart});
  final ApiClient api;
  final CartController cart;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Seu carrinho')),
        body: AnimatedBuilder(
          animation: cart,
          builder: (context, _) {
            if (cart.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: const BoxDecoration(color: AppTheme.paper, shape: BoxShape.circle),
                        child: const Icon(Icons.shopping_bag_outlined, size: 42, color: AppTheme.bark),
                      ),
                      const SizedBox(height: 18),
                      Text('Seu carrinho está vazio', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 7),
                      const Text('Escolha algo gostoso no cardápio para continuar.', textAlign: TextAlign.center),
                      const SizedBox(height: 18),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.restaurant_menu_rounded),
                        label: const Text('Voltar ao cardápio'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                    itemCount: cart.lines.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final line = cart.lines[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(color: AppTheme.paper, borderRadius: BorderRadius.circular(14)),
                              child: const Icon(Icons.lunch_dining_rounded, color: AppTheme.bark),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(line.product.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 4),
                                  Text(formatBRL(line.lineTotalCents), style: const TextStyle(color: AppTheme.ember, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                            _QuantityControl(
                              quantity: line.quantity,
                              onMinus: () => cart.decrement(line.product),
                              onPlus: () => cart.add(line.product),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                    decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE9DFD2)))),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(child: Text('Subtotal', style: TextStyle(color: AppTheme.muted))),
                            Text(formatBRL(cart.subtotalCents), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Taxa de entrega, se aplicável, é confirmada pela loja.', style: TextStyle(color: AppTheme.muted, fontSize: 11)),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                              builder: (_) => CheckoutScreen(api: api, cart: cart),
                            )),
                            child: const Text('Continuar para entrega'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({required this.quantity, required this.onMinus, required this.onPlus});
  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: AppTheme.paper, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: onMinus, visualDensity: VisualDensity.compact, icon: const Icon(Icons.remove_rounded, size: 18)),
            Text('$quantity', style: const TextStyle(fontWeight: FontWeight.w900)),
            IconButton(onPressed: onPlus, visualDensity: VisualDensity.compact, icon: const Icon(Icons.add_rounded, size: 18)),
          ],
        ),
      );
}
