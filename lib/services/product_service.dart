import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class ProductService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ProductModel>> getProducts({
    int offset = 0,
    int limit = 30,
    String? title,
    int? categoryId,
  }) async {
    final Map<String, dynamic> queryParams = {
      'offset': offset,
      'limit': limit,
    };

    if (title != null && title.trim().isNotEmpty) {
      queryParams['title'] = title.trim();
    }
    if (categoryId != null && categoryId > 0) {
      queryParams['categoryId'] = categoryId;
    }

    final response = await _apiClient.get(
      ApiConstants.products,
      queryParameters: queryParams,
    );

    if (response.data is List) {
      return (response.data as List)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<ProductModel> getProductById(int id) async {
    final response = await _apiClient.get(ApiConstants.productById(id));
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<CategoryModel>> getCategories({int limit = 10}) async {
    final response = await _apiClient.get(
      ApiConstants.categories,
      queryParameters: {'limit': limit},
    );

    if (response.data is List) {
      return (response.data as List)
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<ProductModel>> getProductsByCategory(
    int categoryId, {
    int offset = 0,
    int limit = 30,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.categoryProducts(categoryId),
      queryParameters: {
        'offset': offset,
        'limit': limit,
      },
    );

    if (response.data is List) {
      return (response.data as List)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
