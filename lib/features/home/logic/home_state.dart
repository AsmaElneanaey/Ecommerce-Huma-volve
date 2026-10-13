import '../data/models/category_model.dart';
import '../data/models/product_model.dart';

enum HomeStatus { initial, loading, success, error }

class HomeState {
  final HomeStatus status;
  final bool isProductsLoading;
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final String searchQuery;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.isProductsLoading = false,
    this.products = const [],
    this.categories = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    bool? isProductsLoading,
    List<ProductModel>? products,
    List<CategoryModel>? categories,
    int? selectedCategoryId,
    bool clearSelectedCategory = false,
    String? searchQuery,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      isProductsLoading: isProductsLoading ?? this.isProductsLoading,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategoryId: clearSelectedCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
