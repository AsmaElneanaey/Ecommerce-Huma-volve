import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repository;
  Timer? _searchDebounce;

  HomeCubit(this._repository) : super(const HomeState());

  Future<void> loadHomeData() async {
    emit(state.copyWith(status: HomeStatus.loading, isProductsLoading: true));
    try {
      final results = await Future.wait([
        _repository.getCategories(),
        _repository.getProducts(),
      ]);

      final categories = results[0] as dynamic;
      final products = results[1] as dynamic;

      emit(
        state.copyWith(
          status: HomeStatus.success,
          isProductsLoading: false,
          categories: categories,
          products: products,
          clearSelectedCategory: true,
          searchQuery: '',
          errorMessage: null,
        ),
      );
    } catch (e) {
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
    emit(
      state.copyWith(
        selectedCategoryId: isAll ? null : categoryId,
        clearSelectedCategory: isAll,
        isProductsLoading: true,
      ),
    );

    try {
      final products = await _repository.getProducts(
        categoryId: isAll ? null : categoryId,
        title: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );
      emit(
        state.copyWith(
          products: products,
          isProductsLoading: false,
          status: HomeStatus.success,
        ),
      );
    } catch (e) {
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
    emit(state.copyWith(searchQuery: query, isProductsLoading: true));
    try {
      final products = await _repository.getProducts(
        categoryId: state.selectedCategoryId,
        title: query.trim().isNotEmpty ? query.trim() : null,
      );
      emit(
        state.copyWith(
          products: products,
          isProductsLoading: false,
          status: HomeStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isProductsLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
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
