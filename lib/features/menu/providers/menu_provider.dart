import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shalmoneh_app/features/menu/data/models/product_model.dart';
import 'package:shalmoneh_app/features/menu/data/repositories/menu_repository.dart';

/// Provider للتصنيفات من API
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  return await MenuRepository.instance.getCategories();
});

/// Provider للمنتجات — يقبل فلاتر
final productsProvider = FutureProvider.family<List<ProductModel>, ProductFilter>((ref, filter) async {
  return await MenuRepository.instance.getProducts(
    categoryId: filter.categoryId,
    search: filter.search,
    popular: filter.popular,
  );
});

/// Provider للمنتجات الشعبية
final popularProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  return await MenuRepository.instance.getProducts(popular: true);
});

/// فلتر المنتجات
class ProductFilter {
  final String? categoryId;
  final String? search;
  final bool popular;

  const ProductFilter({this.categoryId, this.search, this.popular = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductFilter &&
          categoryId == other.categoryId &&
          search == other.search &&
          popular == other.popular;

  @override
  int get hashCode => Object.hash(categoryId, search, popular);
}
