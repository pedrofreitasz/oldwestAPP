class MenuCategory {
  const MenuCategory({required this.id, required this.name, this.description});

  final int id;
  final String name;
  final String? description;

  factory MenuCategory.fromJson(Map<String, dynamic> json) => MenuCategory(
        id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
        name: json['name']?.toString() ?? 'Categoria',
        description: json['description']?.toString(),
      );
}
