import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onAdd, this.onTap});

  final Product product;
  final VoidCallback onAdd;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: SizedBox(
                    width: 104,
                    height: 104,
                    child: product.imageUrl == null
                        ? const _FoodPlaceholder()
                        : Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const _FoodPlaceholder(),
                            loadingBuilder: (context, child, progress) => progress == null
                                ? child
                                : const _FoodPlaceholder(showLoader: true),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.categoryName != null)
                        Text(
                          product.categoryName!.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.ember,
                            fontSize: 10,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      const SizedBox(height: 5),
                      Text(product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium),
                      if (product.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          product.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 9),
                      Text(formatBRL(product.priceCents),
                          style: const TextStyle(
                            color: AppTheme.ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          )),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                IconButton.filled(
                  onPressed: product.available ? onAdd : null,
                  tooltip: 'Adicionar ${product.name} ao carrinho',
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.ember,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.paper,
                  ),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
        ),
      );
}

class _FoodPlaceholder extends StatelessWidget {
  const _FoodPlaceholder({this.showLoader = false});
  final bool showLoader;

  @override
  Widget build(BuildContext context) => Container(
        color: AppTheme.paper,
        child: Center(
          child: showLoader
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.ember),
                )
              : const Icon(Icons.lunch_dining_rounded, size: 38, color: AppTheme.bark),
        ),
      );
}
