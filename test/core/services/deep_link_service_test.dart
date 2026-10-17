import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app_huma_volve/core/services/deep_link_service.dart';

void main() {
  group('DeepLinkService URI Parsing Tests', () {
    test('extractProductId parses custom scheme ecommerce://product/{id}', () {
      expect(DeepLinkService.extractProductId('ecommerce://product/1'), '1');
      expect(DeepLinkService.extractProductId('ecommerce://product/42'), '42');
      expect(
        DeepLinkService.extractProductId('ecommerce://product/item_abc-123'),
        'item_abc-123',
      );
    });

    test('extractProductId parses custom scheme variants', () {
      expect(DeepLinkService.extractProductId('ecommerce://products/2'), '2');
      expect(DeepLinkService.extractProductId('ecommerce://details/3'), '3');
      expect(DeepLinkService.extractProductId('ecommerce://product?id=4'), '4');
    });

    test('extractProductId parses universal https:// links', () {
      expect(
        DeepLinkService.extractProductId('https://ecommerce.com/product/1'),
        '1',
      );
      expect(
        DeepLinkService.extractProductId('https://ecommerce.com/products/2'),
        '2',
      );
      expect(
        DeepLinkService.extractProductId('https://ecommerce.com/product?id=3'),
        '3',
      );
    });

    test('extractProductId parses relative path routes', () {
      expect(DeepLinkService.extractProductId('/product/1'), '1');
      expect(DeepLinkService.extractProductId('/products/2'), '2');
      expect(DeepLinkService.extractProductId('/product?id=3'), '3');
    });

    test('extractProductId returns null for invalid or irrelevant links', () {
      expect(DeepLinkService.extractProductId(null), isNull);
      expect(DeepLinkService.extractProductId(''), isNull);
      expect(DeepLinkService.extractProductId('   '), isNull);
      expect(DeepLinkService.extractProductId('/home'), isNull);
      expect(DeepLinkService.extractProductId('ecommerce://cart'), isNull);
      expect(DeepLinkService.extractProductId('https://google.com'), isNull);
    });

    test('buildProductUri and buildWebUri generate correct deep links', () {
      expect(
        DeepLinkService.buildProductUri('5'),
        'ecommerce://product/5',
      );
      expect(
        DeepLinkService.buildWebUri('5'),
        'https://ecommerce.com/product/5',
      );
    });
  });
}
