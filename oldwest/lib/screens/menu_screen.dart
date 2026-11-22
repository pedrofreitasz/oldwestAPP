import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/api_client.dart';
import '../state/cart_controller.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, required this.api, required this.cart});
  final ApiClient api;
  final CartController cart;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Future<_MenuData> _menuFuture;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'Todos';

  @override
  void initState() {
    super.initState();
    _menuFuture = _loadMenu();
  }

  Future<_MenuData> _loadMenu() async {
    final results = await Future.wait([
      widget.api.fetchCategories(),
      widget.api.fetchProducts(),
    ]);
    return _MenuData(
      categories: results[0] as List<MenuCategory>,
      products: results[1] as List<Product>,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCart() => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => CartScreen(api: widget.api, cart: widget.cart),
      ));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          titleSpacing: 20,
          title: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.ink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_fire_department_rounded,
                    color: Color(0xFFFFC46B), size: 23),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LANCHONETE', style: TextStyle(fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.w900, color: AppTheme.muted)),
                  Text('Lanche no Fogo', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppTheme.ink)),
                ],
              ),
            ],
          ),
          actions: [
            AnimatedBuilder(
              animation: widget.cart,
              builder: (context, _) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: _openCart,
                      tooltip: 'Abrir carrinho',
                      icon: const Icon(Icons.shopping_bag_outlined, size: 25),
                    ),
                    if (widget.cart.itemCount > 0)
                      Positioned(
                        right: 1,
                        top: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: const BoxDecoration(color: AppTheme.ember, shape: BoxShape.circle),
                          child: Text('${widget.cart.itemCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: FutureBuilder<_MenuData>(
          future: _menuFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.ember));
            }
            if (snapshot.hasError) {
              return _LoadError(
                error: snapshot.error.toString(),
                onRetry: () => setState(() => _menuFuture = _loadMenu()),
              );
            }
            final data = snapshot.data!;
            final categories = ['Todos', ...data.categories.map((category) => category.name)];
            final products = data.products.where((product) {
              final matchesCategory = _selectedCategory == 'Todos' || product.categoryName == _selectedCategory;
              final needle = _query.trim().toLowerCase();
              final matchesSearch = needle.isEmpty || product.name.toLowerCase().contains(needle) ||
                  (product.description?.toLowerCase().contains(needle) ?? false);
              return matchesCategory && matchesSearch;
            }).toList();

            return RefreshIndicator(
              color: AppTheme.ember,
              onRefresh: () async => setState(() => _menuFuture = _loadMenu()),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _hero(context)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _query = value),
                        decoration: InputDecoration(
                          hintText: 'O que vai matar sua fome?',
                          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.muted),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _query = '');
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 48,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final name = categories[index];
                          final selected = name == _selectedCategory;
                          return ChoiceChip(
                            label: Text(name),
                            selected: selected,
                            onSelected: (_) => setState(() => _selectedCategory = name),
                            backgroundColor: Colors.white,
                            selectedColor: AppTheme.ink,
                            labelStyle: TextStyle(
                              color: selected ? Colors.white : AppTheme.bark,
                              fontWeight: FontWeight.w700,
                            ),
                            side: BorderSide(color: selected ? AppTheme.ink : const Color(0xFFE9DFD2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          );
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Row(
                        children: [
                          Expanded(child: Text('Feito na brasa', style: Theme.of(context).textTheme.titleLarge)),
                          Text('${products.length} ${products.length == 1 ? 'opção' : 'opções'}', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                  if (products.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(30),
                          child: Text('Não encontramos itens por aqui. Tente outra busca ou categoria.', textAlign: TextAlign.center),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index.isOdd) return const SizedBox(height: 12);
                            final product = products[index ~/ 2];
                            return ProductCard(
                              product: product,
                              onAdd: () {
                                widget.cart.add(product);
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(SnackBar(
                                    content: Text('${product.name} adicionado ao carrinho'),
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ));
                              },
                              onTap: () => _showProduct(context, product),
                            );
                          },
                          childCount: products.length * 2 - 1,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: AnimatedBuilder(
          animation: widget.cart,
          builder: (context, _) => widget.cart.isEmpty
              ? const SizedBox.shrink()
              : SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: FilledButton.icon(
                      onPressed: _openCart,
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: Text('Ver carrinho · ${formatBRL(widget.cart.subtotalCents)}'),
                    ),
                  ),
                ),
        ),
      );

  Widget _hero(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        padding: const EdgeInsets.fromLTRB(22, 23, 18, 20),
        decoration: BoxDecoration(
          color: AppTheme.ink,
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF30221A), Color(0xFF593A27)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(color: const Color(0x33FFC46B), borderRadius: BorderRadius.circular(20)),
                    child: const Text('SABOR DE VERDADE', style: TextStyle(color: Color(0xFFFFC46B), fontSize: 9, letterSpacing: 1.3, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(height: 13),
                  Text('A fome não\nespera.', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontSize: 28)),
                  const SizedBox(height: 7),
                  const Text('Escolha seu favorito e peça agora.', style: TextStyle(color: Color(0xFFD8C5B2), fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.lunch_dining_rounded, color: Color(0xFFFFC46B), size: 72),
          ],
        ),
      );

  void _showProduct(BuildContext context, Product product) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppTheme.cream,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24)),
            if (product.description != null) ...[
              const SizedBox(height: 10),
              Text(product.description!),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: Text(formatBRL(product.priceCents), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
                FilledButton.icon(
                  onPressed: () {
                    widget.cart.add(product);
                    Navigator.pop(sheetContext);
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuData {
  const _MenuData({required this.categories, required this.products});
  final List<MenuCategory> categories;
  final List<Product> products;
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, color: AppTheme.ember, size: 46),
              const SizedBox(height: 16),
              Text('Não conseguimos abrir o cardápio', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(error, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 18),
              FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('Tentar novamente')),
            ],
          ),
        ),
      );
}
