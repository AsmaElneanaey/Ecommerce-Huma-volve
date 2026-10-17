import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app_huma_volve/core/dummy_data.dart';
import 'package:ecommerce_app_huma_volve/features/details/screens/product_details_screen.dart';

const List<int> _kTransparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];

class _FakeHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest();
}

class _FakeHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();
}

class _FakeHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}


class _FakeHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_kTransparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

class _FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FakeHttpClient();
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _FakeHttpOverrides();
  });

  group('ProductDetailsScreen Deep Link Tests', () {
    testWidgets('renders product details screen when opened with valid productId', (
      WidgetTester tester,
    ) async {
      final expectedProduct = dummyProducts.first;

      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailsScreen(productId: expectedProduct.id),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(expectedProduct.name), findsOneWidget);
      expect(find.text(expectedProduct.description), findsOneWidget);
      expect(
        find.text('\$${expectedProduct.price.toStringAsFixed(2)}'),
        findsOneWidget,
      );
      expect(find.text('Add to Cart'), findsOneWidget);
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
    });

    testWidgets('renders Product Not Found view when opened with invalid productId', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProductDetailsScreen(productId: '99999_non_existent'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Product Not Found'), findsOneWidget);
      expect(
        find.text('No product found with ID "99999_non_existent".'),
        findsOneWidget,
      );
      expect(find.text('Explore Products'), findsOneWidget);
    });

    testWidgets('tapping share/copy deep link copies link to clipboard and shows snackbar', (
      WidgetTester tester,
    ) async {
      final expectedProduct = dummyProducts.first;

      await tester.pumpWidget(
        MaterialApp(
          home: ProductDetailsScreen(productId: expectedProduct.id),
        ),
      );
      await tester.pumpAndSettle();

      final shareButton = find.byIcon(Icons.share_outlined);
      expect(shareButton, findsOneWidget);

      await tester.tap(shareButton);
      await tester.pump();

      expect(
        find.text('Deep link copied: ecommerce://product/${expectedProduct.id}'),
        findsOneWidget,
      );
    });
  });
}
