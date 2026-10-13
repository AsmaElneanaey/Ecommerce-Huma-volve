import 'package:flutter/material.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> images;
  final List<Color> colors;
  final List<String> sizes;
  final int? categoryId;
  final String? categoryName;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.images = const [],
    this.colors = const [
      Color(0xFF2C3E50),
      Color(0xFFE74C3C),
      Color(0xFF3498DB),
      Color(0xFF95A5A6),
    ],
    this.sizes = const ['S', 'M', 'L', 'XL'],
    this.categoryId,
    this.categoryName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    List<String> parsedImages = [];

    if (rawImages is List) {
      for (var item in rawImages) {
        final cleaned = _cleanImageUrl(item);
        if (cleaned.isNotEmpty) {
          parsedImages.add(cleaned);
        }
      }
    }

    final id = json['id']?.toString() ?? '0';
    final fallbackUrl = 'https://picsum.photos/seed/$id/400/400';
    final primaryImageUrl = parsedImages.isNotEmpty ? parsedImages.first : fallbackUrl;

    if (parsedImages.isEmpty) {
      parsedImages.add(primaryImageUrl);
    }

    final priceRaw = json['price'];
    final price = priceRaw is num
        ? priceRaw.toDouble()
        : double.tryParse(priceRaw?.toString() ?? '0') ?? 0.0;

    int? catId;
    String? catName;
    if (json['category'] is Map) {
      final catMap = json['category'] as Map<String, dynamic>;
      catId = catMap['id'] is int
          ? catMap['id'] as int
          : int.tryParse(catMap['id']?.toString() ?? '');
      catName = catMap['name']?.toString();
    }

    return ProductModel(
      id: id,
      name: json['title']?.toString() ?? json['name']?.toString() ?? 'Product',
      description: json['description']?.toString() ?? '',
      price: price,
      imageUrl: primaryImageUrl,
      images: parsedImages,
      categoryId: catId,
      categoryName: catName,
      colors: const [
        Color(0xFF2C3E50),
        Color(0xFFE74C3C),
        Color(0xFF3498DB),
        Color(0xFF95A5A6),
      ],
      sizes: const ['S', 'M', 'L', 'XL'],
    );
  }

  static String _cleanImageUrl(dynamic raw) {
    if (raw == null) return '';
    String url = raw.toString();
    // Remove extra JSON escape quotes or brackets if present in EscuelaJS
    url = url.replaceAll(RegExp(r'[\[\]\\"]'), '').trim();
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': name,
      'description': description,
      'price': price,
      'images': images,
      if (categoryId != null) 'categoryId': categoryId,
    };
  }
}
