import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';

enum HomeStatus { initial, loading, success, error }

class HomeState {
  final HomeStatus status;
  final bool isProductsLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final List<ProductEntity> products;
  final List<CategoryEntity> categories;
  final int? selectedCategoryId;
  final String searchQuery;
  final String? errorMessage;
  final String? paginationErrorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.isProductsLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.products = const [],
    this.categories = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.errorMessage,
    this.paginationErrorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    bool? isProductsLoading,
    bool? isLoadingMore,
    bool? hasMore,
    List<ProductEntity>? products,
    List<CategoryEntity>? categories,
    int? selectedCategoryId,
    bool clearSelectedCategory = false,
    String? searchQuery,
    String? errorMessage,
    String? paginationErrorMessage,
    bool clearPaginationError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      isProductsLoading: isProductsLoading ?? this.isProductsLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategoryId: clearSelectedCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
      paginationErrorMessage: clearPaginationError
          ? null
          : (paginationErrorMessage ?? this.paginationErrorMessage),
    );
  }
}

