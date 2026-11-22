class Product {
  const Product({
    required this.id,
    required this.name,
    required this.priceCents,
    this.description,
    this.categoryName,
    this.imageUrl,
    this.available = true,
  });

  final int id;
  final String name;
  final int priceCents;
  final String? description;
  final String? categoryName;
  final String? imageUrl;
  final bool available;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? 'Produto',
      priceCents: _asInt(json['price_cents']),
      description: _asNullableString(json['description']),
      categoryName: _asNullableString(json['category_name']),
      imageUrl: _asNullableString(json['image_url']),
      available: _asInt(json['available'], fallback: 1) == 1,
    );
  }
}

int _asInt(Object? value, {int fallback = 0}) =>
    value is int ? value : int.tryParse('$value') ?? fallback;

String? _asNullableString(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
