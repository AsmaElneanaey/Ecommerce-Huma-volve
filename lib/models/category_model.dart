class CategoryModel {
  final int id;
  final String name;
  final String image;
  final String? slug;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    this.slug,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      slug: json['slug'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      if (slug != null) 'slug': slug,
    };
  }
}
