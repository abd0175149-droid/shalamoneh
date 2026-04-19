import 'package:shalmoneh_app/core/network/api_client.dart';
import 'package:shalmoneh_app/core/network/api_endpoints.dart';
import 'package:shalmoneh_app/features/menu/data/models/product_model.dart';

/// مستودع البيانات — يجلب التصنيفات والمنتجات من API
class MenuRepository {
  MenuRepository._();
  static final MenuRepository instance = MenuRepository._();

  List<CategoryModel>? _cachedCategories;
  final Map<String, List<ProductModel>> _cachedProducts = {};

  /// جلب التصنيفات
  Future<List<CategoryModel>> getCategories() async {
    if (_cachedCategories != null) return _cachedCategories!;

    final response = await apiClient.get(ApiEndpoints.categories);
    if (response.success && response.data != null) {
      final list = response.data as List<dynamic>;
      _cachedCategories = list
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return _cachedCategories!;
    }
    return [];
  }

  /// جلب المنتجات (مع فلاتر اختيارية)
  Future<List<ProductModel>> getProducts({
    String? categoryId,
    String? search,
    bool popular = false,
  }) async {
    final cacheKey = '${categoryId ?? 'all'}_${search ?? ''}_$popular';
    if (_cachedProducts.containsKey(cacheKey)) return _cachedProducts[cacheKey]!;

    final queryParams = <String, String>{};
    if (categoryId != null) queryParams['category'] = categoryId;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (popular) queryParams['popular'] = 'true';

    final response = await apiClient.get(
      ApiEndpoints.products,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response.success && response.data != null) {
      final list = response.data as List<dynamic>;
      final products = list
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _cachedProducts[cacheKey] = products;
      return products;
    }
    return [];
  }

  /// جلب منتج بالـ ID
  Future<ProductModel?> getProductById(String id) async {
    final response = await apiClient.get(ApiEndpoints.productById(id));
    if (response.success && response.data != null) {
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    }
    return null;
  }

  /// مسح الكاش
  void clearCache() {
    _cachedCategories = null;
    _cachedProducts.clear();
  }
}
