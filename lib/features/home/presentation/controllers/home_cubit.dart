import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  static const int pageSize = 10;

  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetProductsUseCase _getProductsUseCase;
  Timer? _searchDebounce;

  HomeCubit({
    required GetCategoriesUseCase getCategoriesUseCase,
    required GetProductsUseCase getProductsUseCase,
  })  : _getCategoriesUseCase = getCategoriesUseCase,
        _getProductsUseCase = getProductsUseCase,
        super(const HomeState());

  Future<void> loadHomeData() async {
    emit(state.copyWith(
      status: HomeStatus.loading,
      isProductsLoading: true,
      isLoadingMore: false,
      hasMore: true,
      clearPaginationError: true,
    ));
    try {
      final results = await Future.wait([
        _getCategoriesUseCase(const NoParams()),
        _getProductsUseCase(
          const GetProductsParams(offset: 0, limit: pageSize),
        ),
      ]);

      if (isClosed) return;

      final categories = results[0] as List<CategoryEntity>;
      final products = results[1] as List<ProductEntity>;

      emit(
        state.copyWith(
          status: HomeStatus.success,
          isProductsLoading: false,
          categories: categories,
          products: products,
          hasMore: products.length >= pageSize,
          clearSelectedCategory: true,
          searchQuery: '',
          errorMessage: null,
          clearPaginationError: true,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: HomeStatus.error,
          isProductsLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> selectCategory(int? categoryId) async {
    if (state.selectedCategoryId == categoryId) return;

    final isAll = categoryId == null || categoryId <= 0;
    final targetCategoryId = isAll ? null : categoryId;

    emit(
      state.copyWith(
        selectedCategoryId: targetCategoryId,
        clearSelectedCategory: isAll,
        isProductsLoading: true,
        isLoadingMore: false,
        hasMore: true,
        clearPaginationError: true,
      ),
    );

    try {
      final products = await _getProductsUseCase(
        GetProductsParams(
          categoryId: targetCategoryId,
          title: state.searchQuery.isNotEmpty ? state.searchQuery : null,
          offset: 0,
          limit: pageSize,
        ),
      );

      if (isClosed || state.selectedCategoryId != targetCategoryId) return;

      emit(
        state.copyWith(
          products: products,
          hasMore: products.length >= pageSize,
          isProductsLoading: false,
          status: HomeStatus.success,
          clearPaginationError: true,
        ),
      );
    } catch (e) {
      if (isClosed || state.selectedCategoryId != targetCategoryId) return;
      emit(
        state.copyWith(
          isProductsLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _executeSearch(query);
    });
  }

  Future<void> _executeSearch(String query) async {
    final trimmedQuery = query.trim();
    emit(state.copyWith(
      searchQuery: query,
      isProductsLoading: true,
      isLoadingMore: false,
      hasMore: true,
      clearPaginationError: true,
    ));

    try {
      final products = await _getProductsUseCase(
        GetProductsParams(
          categoryId: state.selectedCategoryId,
          title: trimmedQuery.isNotEmpty ? trimmedQuery : null,
          offset: 0,
          limit: pageSize,
        ),
      );

      if (isClosed || state.searchQuery != query) return;

      emit(
        state.copyWith(
          products: products,
          hasMore: products.length >= pageSize,
          isProductsLoading: false,
          status: HomeStatus.success,
          clearPaginationError: true,
        ),
      );
    } catch (e) {
      if (isClosed || state.searchQuery != query) return;
      emit(
        state.copyWith(
          isProductsLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> loadMoreProducts() async {
    if (state.isLoadingMore ||
        !state.hasMore ||
        state.isProductsLoading ||
        state.status == HomeStatus.loading) {
      return;
    }

    final currentCategoryId = state.selectedCategoryId;
    final currentSearchQuery = state.searchQuery;

    emit(state.copyWith(
      isLoadingMore: true,
      clearPaginationError: true,
    ));

    try {
      final newProducts = await _getProductsUseCase(
        GetProductsParams(
          categoryId: currentCategoryId,
          title: currentSearchQuery.trim().isNotEmpty
              ? currentSearchQuery.trim()
              : null,
          offset: state.products.length,
          limit: pageSize,
        ),
      );

      if (isClosed ||
          state.selectedCategoryId != currentCategoryId ||
          state.searchQuery != currentSearchQuery) {
        return;
      }

      final existingIds = state.products.map((p) => p.id).toSet();
      final uniqueNewProducts =
          newProducts.where((p) => !existingIds.contains(p.id)).toList();

      final hasMore =
          newProducts.length >= pageSize && uniqueNewProducts.isNotEmpty;

      emit(
        state.copyWith(
          products: [...state.products, ...uniqueNewProducts],
          isLoadingMore: false,
          hasMore: hasMore,
          clearPaginationError: true,
        ),
      );
    } catch (e) {
      if (isClosed ||
          state.selectedCategoryId != currentCategoryId ||
          state.searchQuery != currentSearchQuery) {
        return;
      }

      emit(
        state.copyWith(
          isLoadingMore: false,
          paginationErrorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
