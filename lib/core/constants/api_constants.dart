class ApiConstants {
  static const String baseUrl = 'https://api.escuelajs.co/api/v1';

  static const String products = '/products';
  static String productById(int id) => '/products/$id';

  static const String categories = '/categories';
  static String categoryProducts(int categoryId) => '/categories/$categoryId/products';

  static const String login = '/auth/login';
  static const String profile = '/auth/profile';
  static const String refreshToken = '/auth/refresh-token';

  static const String users = '/users';
  static String userById(int id) => '/users/$id';
}
