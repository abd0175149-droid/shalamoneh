/// نموذج التصنيف
class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final int sortOrder;
  final bool isActive;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? '🥤',
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

/// نموذج الإضافة
class AddonModel {
  final String id;
  final String name;
  final double price;
  final bool isAvailable;

  const AddonModel({
    required this.id,
    required this.name,
    required this.price,
    this.isAvailable = true,
  });

  factory AddonModel.fromJson(Map<String, dynamic> json) {
    return AddonModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }
}

/// نموذج المنتج الكامل
class ProductModel {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final String imageUrl;
  final double priceS;
  final double priceM;
  final double priceL;
  final List<AddonModel> availableAddons;
  final bool isAvailable;
  final bool isPopular;

  const ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description = '',
    this.imageUrl = '',
    required this.priceS,
    required this.priceM,
    required this.priceL,
    this.availableAddons = const [],
    this.isAvailable = true,
    this.isPopular = false,
  });

  /// إرجاع السعر حسب الحجم
  double priceForSize(String size) {
    switch (size) {
      case 'S': return priceS;
      case 'M': return priceM;
      case 'L': return priceL;
      default: return priceM;
    }
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      priceS: (json['price_s'] as num).toDouble(),
      priceM: (json['price_m'] as num).toDouble(),
      priceL: (json['price_l'] as num).toDouble(),
      availableAddons: (json['addons'] as List<dynamic>?)
              ?.map((a) => AddonModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      isAvailable: json['is_available'] as bool? ?? true,
      isPopular: json['is_popular'] as bool? ?? false,
    );
  }
}
