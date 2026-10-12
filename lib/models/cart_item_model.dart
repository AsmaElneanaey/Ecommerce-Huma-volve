import 'package:flutter/material.dart';
import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;
  final Color selectedColor;
  final String selectedSize;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    required this.selectedColor,
    required this.selectedSize,
  });

  double get totalPrice => product.price * quantity;
}
