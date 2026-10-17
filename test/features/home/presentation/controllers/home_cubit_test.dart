import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/entities/category_entity.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/entities/product_entity.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/repositories/home_repository.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/usecases/get_categories_usecase.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/usecases/get_products_usecase.dart';
import 'package:ecommerce_app_huma_volve/features/home/presentation/controllers/home_cubit.dart';
import 'package:ecommerce_app_huma_volve/features/home/presentation/controllers/home_state.dart';

class FakeHomeRepository implements HomeRepository {
  List<CategoryEntity> categories = [
    const CategoryEntity(id: 1, name: 'Clothes', image: 'url1'),
    const CategoryEntity(id: 2, name: 'Electronics', image: 'url2'),
  ];

  List<ProductEntity> Function({
    int? categoryId,
    String? title,
    int offset,
    int limit,
  })? onGetProducts;

  @override
  Future<List<CategoryEntity>> getCategories() async => categories;

  @override
  Future<List<ProductEntity>> getProducts({
    int? categoryId,
    String? title,
    int offset = 0,
    int limit = 20,
  }) async {
    if (onGetProducts != null) {
      return onGetProducts!(
        categoryId: categoryId,
        title: title,
        offset: offset,
        limit: limit,
      );
    }
    return [];
  }
}

ProductEntity _createProduct(String id, {String name = 'Product'}) {
  return ProductEntity(
    id: id,
    name: name,
    description: 'Description for $id',
    price: 99.99,
    imageUrl: 'https://example.com/$id.png',
  );
}

void main() {
  late FakeHomeRepository fakeRepo;
  late HomeCubit cubit;

  setUp(() {
    fakeRepo = FakeHomeRepository();
    cubit = HomeCubit(
      getCategoriesUseCase: GetCategoriesUseCase(fakeRepo),
      getProductsUseCase: GetProductsUseCase(fakeRepo),
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('HomeCubit Pagination Tests', () {
    test('loadHomeData loads initial page (offset: 0, limit: 10) and sets hasMore', () async {
      int capturedOffset = -1;
      int capturedLimit = -1;

      fakeRepo.onGetProducts = ({categoryId, title, offset = 0, limit = 20}) {
        capturedOffset = offset;
        capturedLimit = limit;
        return List.generate(10, (i) => _createProduct('$i'));
      };

      await cubit.loadHomeData();

      expect(capturedOffset, 0);
      expect(capturedLimit, HomeCubit.pageSize);
      expect(cubit.state.status, HomeStatus.success);
      expect(cubit.state.products.length, 10);
      expect(cubit.state.hasMore, isTrue);
      expect(cubit.state.isLoadingMore, isFalse);
      expect(cubit.state.paginationErrorMessage, isNull);
    });

    test('loadHomeData sets hasMore to false when first page has fewer than pageSize items', () async {
      fakeRepo.onGetProducts = ({categoryId, title, offset = 0, limit = 20}) {
        return List.generate(4, (i) => _createProduct('$i'));
      };

      await cubit.loadHomeData();

      expect(cubit.state.products.length, 4);
      expect(cubit.state.hasMore, isFalse);
    });

    test('loadMoreProducts requests next page with offset = products.length and appends items', () async {
      int fetchCount = 0;
      final offsets = <int>[];

      fakeRepo.onGetProducts = ({categoryId, title, offset = 0, limit = 20}) {
        fetchCount++;
        offsets.add(offset);
        if (fetchCount == 1) {
          return List.generate(10, (i) => _createProduct('p$i'));
        } else {
          return List.generate(10, (i) => _createProduct('p${i + 10}'));
        }
      };

      await cubit.loadHomeData();
      expect(cubit.state.products.length, 10);
      expect(cubit.state.hasMore, isTrue);

      await cubit.loadMoreProducts();

      expect(offsets, [0, 10]);
      expect(cubit.state.products.length, 20);
      expect(cubit.state.products.first.id, 'p0');
      expect(cubit.state.products.last.id, 'p19');
      expect(cubit.state.hasMore, isTrue);
      expect(cubit.state.isLoadingMore, isFalse);
    });

    test('loadMoreProducts deduplicates products and sets hasMore = false when end reached', () async {
      int fetchCount = 0;

      fakeRepo.onGetProducts = ({categoryId, title, offset = 0, limit = 20}) {
        fetchCount++;
        if (fetchCount == 1) {
          return List.generate(10, (i) => _createProduct('p$i'));
        } else {
          // Returns 3 new products (less than pageSize)
          return [
            _createProduct('p10'),
            _createProduct('p11'),
            _createProduct('p12'),
          ];
        }
      };

      await cubit.loadHomeData();
      await cubit.loadMoreProducts();

      expect(cubit.state.products.length, 13);
      expect(cubit.state.hasMore, isFalse);
    });

    test('loadMoreProducts does nothing if hasMore is false', () async {
      int calls = 0;
      fakeRepo.onGetProducts = ({categoryId, title, offset = 0, limit = 20}) {
        calls++;
        return [_createProduct('single')];
      };

      await cubit.loadHomeData();
      expect(calls, 1);
      expect(cubit.state.hasMore, isFalse);

      await cubit.loadMoreProducts();
      expect(calls, 1); // Not called again
    });

    test('loadMoreProducts sets paginationErrorMessage on error without clearing existing products', () async {
      int fetchCount = 0;

      fakeRepo.onGetProducts = ({categoryId, title, offset = 0, limit = 20}) {
        fetchCount++;
        if (fetchCount == 1) {
          return List.generate(10, (i) => _createProduct('p$i'));
        } else {
          throw Exception('Network connection timed out');
        }
      };

      await cubit.loadHomeData();
      expect(cubit.state.products.length, 10);

      await cubit.loadMoreProducts();

      expect(cubit.state.products.length, 10);
      expect(cubit.state.isLoadingMore, isFalse);
      expect(cubit.state.paginationErrorMessage, 'Network connection timed out');
      expect(cubit.state.hasMore, isTrue);
    });

    test('selectCategory resets offset to 0 and clears pagination error', () async {
      int lastOffset = -1;
      int? lastCatId;

      fakeRepo.onGetProducts = ({categoryId, title, offset = 0, limit = 20}) {
        lastOffset = offset;
        lastCatId = categoryId;
        return List.generate(10, (i) => _createProduct('cat_${categoryId}_${offset + i}'));
      };

      await cubit.loadHomeData();
      await cubit.loadMoreProducts();
      expect(cubit.state.products.length, 20);

      await cubit.selectCategory(2);

      expect(lastOffset, 0);
      expect(lastCatId, 2);
      expect(cubit.state.selectedCategoryId, 2);
      expect(cubit.state.products.length, 10);
      expect(cubit.state.hasMore, isTrue);
      expect(cubit.state.paginationErrorMessage, isNull);
    });

  });
}
