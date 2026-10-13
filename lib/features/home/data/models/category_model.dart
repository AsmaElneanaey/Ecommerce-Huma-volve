class CategoryModel {
  final int id;
  final String name;
  final String image;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      image: _cleanImageUrl(json['image']),
    );
  }

  static String _cleanImageUrl(dynamic rawUrl) {
    if (rawUrl == null) return '';
    String url = rawUrl.toString();
    url = url.replaceAll(RegExp(r'[\[\]\\"]'), '').trim();
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }
}
