import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app_huma_volve/core/constants/api_constants.dart';
import 'package:ecommerce_app_huma_volve/models/product_model.dart';
import 'package:ecommerce_app_huma_volve/models/category_model.dart';
import 'package:ecommerce_app_huma_volve/models/user_model.dart';
import 'package:ecommerce_app_huma_volve/models/auth_response_model.dart';
import 'package:ecommerce_app_huma_volve/services/cart_service.dart';

void main() {
  group('ApiConstants Tests', () {
    test('Endpoints should match EscuelaJS API specifications', () {
      expect(ApiConstants.baseUrl, 'https://api.escuelajs.co/api/v1');
      expect(ApiConstants.products, '/products');
      expect(ApiConstants.categories, '/categories');
      expect(ApiConstants.login, '/auth/login');
      expect(ApiConstants.profile, '/auth/profile');
      expect(ApiConstants.users, '/users');
    });
  });

  group('Model Serialization Tests', () {
    test('CategoryModel correctly parses json', () {
      final json = {
        'id': 1,
        'name': 'Clothes',
        'image': 'https://placeimg.com/640/480/any',
      };
      final category = CategoryModel.fromJson(json);
      expect(category.id, 1);
      expect(category.name, 'Clothes');
      expect(category.image, 'https://placeimg.com/640/480/any');
    });

    test('ProductModel correctly parses json and cleans image urls', () {
      final json = {
        'id': 12,
        'title': 'Classic Sneakers',
        'price': 49.99,
        'description': 'A pair of classic sneakers.',
        'images': [
          '["https://i.imgur.com/QkIa5tT.jpeg"]',
          'https://i.imgur.com/jb5Yu0h.jpeg'
        ],
        'category': {
          'id': 1,
          'name': 'Shoes',
          'image': 'https://placeimg.com/640/480/any',
        }
      };

      final product = ProductModel.fromJson(json);
      expect(product.id, 12);
      expect(product.title, 'Classic Sneakers');
      expect(product.price, 49.99);
      expect(product.images.length, 2);
      expect(product.images.first, 'https://i.imgur.com/QkIa5tT.jpeg');
      expect(product.category?.name, 'Shoes');
    });

    test('UserModel and AuthResponseModel parse correctly', () {
      final authJson = {
        'access_token': 'test_token',
        'refresh_token': 'refresh_token',
      };
      final auth = AuthResponseModel.fromJson(authJson);
      expect(auth.accessToken, 'test_token');

      final userJson = {
        'id': 1,
        'email': 'john@mail.com',
        'name': 'John Doe',
        'role': 'customer',
        'avatar': 'https://i.pravatar.cc/300',
      };
      final user = UserModel.fromJson(userJson);
      expect(user.id, 1);
      expect(user.email, 'john@mail.com');
      expect(user.name, 'John Doe');
    });
  });

  group('CartService Tests', () {
    test('Adds product and updates totals', () {
      final cart = CartService();
      cart.clearCart();
      expect(cart.isEmpty, isTrue);

      final product = ProductModel(
        id: 101,
        title: 'Running Shoes',
        price: 50.0,
        description: 'Running shoes',
        images: ['https://example.com/shoes.jpg'],
      );

      cart.addToCart(product);
      expect(cart.totalItemCount, 1);
      expect(cart.subtotal, 50.0);
      expect(cart.tax, 5.0);
      expect(cart.total, 55.0);

      cart.incrementQuantity(0);
      expect(cart.totalItemCount, 2);
      expect(cart.subtotal, 100.0);

      cart.decrementQuantity(0);
      expect(cart.totalItemCount, 1);

      cart.clearCart();
      expect(cart.isEmpty, isTrue);
    });
  });
}
