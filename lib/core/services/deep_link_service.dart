import 'package:flutter/material.dart';
import '../../features/details/screens/product_details_screen.dart';

class DeepLinkService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String customScheme = 'ecommerce';
  static const String productHost = 'product';
  static const String productsHost = 'products';
  static const String detailsHost = 'details';
  static const String webDomain = 'ecommerce.com';

  /// Generates a custom scheme deep link URI for a product.
  /// Example: `ecommerce://product/1`
  static String buildProductUri(String productId) {
    return '$customScheme://$productHost/$productId';
  }

  /// Generates a standard web Universal / App link for a product.
  /// Example: `https://ecommerce.com/product/1`
  static String buildWebUri(String productId) {
    return 'https://$webDomain/product/$productId';
  }

  /// Extracts the product ID from any supported deep link format.
  /// Supported formats:
  /// - `ecommerce://product/123`
  /// - `ecommerce://products/123`
  /// - `ecommerce://details/123`
  /// - `ecommerce://product?id=123`
  /// - `https://ecommerce.com/product/123`
  /// - `https://ecommerce.com/products/123`
  /// - `https://ecommerce.com/product?id=123`
  /// - `/product/123`
  /// - `/products/123`
  /// - `/product?id=123`
  static String? extractProductId(String? input) {
    if (input == null || input.trim().isEmpty) return null;

    final trimmed = input.trim();

    try {
      final uri = Uri.parse(trimmed);

      // Check query parameter (e.g. ?id=123)
      if (uri.queryParameters.containsKey('id')) {
        final id = uri.queryParameters['id']?.trim();
        if (id != null && id.isNotEmpty) return id;
      }

      // Check custom scheme URI: ecommerce://product/123
      if (uri.scheme == customScheme) {
        final host = uri.host.toLowerCase();
        if (host == productHost || host == productsHost || host == detailsHost) {
          final segments = uri.pathSegments;
          if (segments.isNotEmpty && segments.first.isNotEmpty) {
            return segments.first;
          }
        }
      }

      // Check HTTP / HTTPS App Links: https://ecommerce.com/product/123
      if (uri.scheme == 'http' || uri.scheme == 'https') {
        final segments = uri.pathSegments;
        if (segments.isNotEmpty) {
          final first = segments.first.toLowerCase();
          if ((first == productHost ||
                  first == productsHost ||
                  first == detailsHost) &&
              segments.length > 1 &&
              segments[1].isNotEmpty) {
            return segments[1];
          }
        }
      }

      // Check relative path route: /product/123 or /products/123
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final first = pathSegments.first.toLowerCase();
        if ((first == productHost ||
                first == productsHost ||
                first == detailsHost) &&
            pathSegments.length > 1 &&
            pathSegments[1].isNotEmpty) {
          return pathSegments[1];
        }
      }
    } catch (_) {}

    // Fallback regular expression matching
    final regExp = RegExp(
      r'(?:product|products|details)(?:/|\?id=)([a-zA-Z0-9_-]+)',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(trimmed);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }

    return null;
  }

  /// Navigates to ProductDetailsScreen if the deep link contains a valid product ID.
  static bool handleDeepLink(String? urlOrPath) {
    final productId = extractProductId(urlOrPath);
    if (productId != null) {
      final navigator = navigatorKey.currentState;
      if (navigator != null) {
        navigator.push(
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(productId: productId),
            settings: RouteSettings(name: '/product/$productId'),
          ),
        );
        return true;
      }
    }
    return false;
  }
}
