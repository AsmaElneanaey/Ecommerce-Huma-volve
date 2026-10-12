import 'package:flutter/material.dart';
import 'category_model.dart';

class ProductModel {
  final int id;
  final String title;
  final double price;
  final String description;
  final List<String> images;
  final CategoryModel? category;
  final List<Color> colors;
  final List<String> sizes;

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.images,
    this.category,
    List<Color>? colors,
    List<String>? sizes,
  })  : colors = colors ?? const [Colors.black, Colors.blueGrey, Colors.brown, Colors.white],
        sizes = sizes ?? const ['S', 'M', 'L', 'XL'];

  String get name => title;

  String get imageUrl {
    if (images.isNotEmpty) {
      return images.first;
    }
    return 'https://placehold.co/400x400/png?text=No+Image';
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    final List<String> parsedImages = [];

    if (rawImages is List) {
      for (final item in rawImages) {
        if (item is String) {
          String cleaned = item.replaceAll(RegExp(r'[\[\]"\\\s]'), '');
          if (cleaned.startsWith('http://') || cleaned.startsWith('https://')) {
            parsedImages.add(cleaned);
          }
        }
      }
    }

    final rawPrice = json['price'];
    final double parsedPrice = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '0') ?? 0.0;

    return ProductModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] as String? ?? 'Unnamed Product',
      price: parsedPrice,
      description: json['description'] as String? ?? '',
      images: parsedImages,
      category: json['category'] is Map<String, dynamic>
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'images': images,
      if (category != null) 'category': category!.toJson(),
    };
  }
}
