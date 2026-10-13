import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class HomeRepository {
  final DioClient _dioClient;

  HomeRepository({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dioClient.get(ApiConstants.categories);
      if (response.data is List) {
        return (response.data as List)
            .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<List<ProductModel>> getProducts({
    int? categoryId,
    String? title,
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'offset': offset,
        'limit': limit,
      };

      if (categoryId != null && categoryId > 0) {
        queryParams['categoryId'] = categoryId;
      }

      if (title != null && title.trim().isNotEmpty) {
        queryParams['title'] = title.trim();
      }

      final response = await _dioClient.get(
        ApiConstants.products,
        queryParameters: queryParams,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }
}
