import 'package:shalmoneh_app/features/menu/data/models/product_model.dart';

/// بيانات Mock للتطوير — تُستبدل ببيانات API حقيقية لاحقاً
class MockData {
  MockData._();

  // ══════════════════════════════════════════
  //  التصنيفات
  // ══════════════════════════════════════════
  static final categories = [
    const CategoryModel(id: 'cat1', name: 'عصائر طبيعية', icon: '🍊', sortOrder: 1),
    const CategoryModel(id: 'cat2', name: 'مكس شلمونة', icon: '🥤', sortOrder: 2),
    const CategoryModel(id: 'cat3', name: 'ساخن', icon: '☕', sortOrder: 3),
    const CategoryModel(id: 'cat4', name: 'حلى', icon: '🍰', sortOrder: 4),
  ];

  // ══════════════════════════════════════════
  //  الإضافات
  // ══════════════════════════════════════════
  static final addons = [
    const AddonModel(id: 'a1', name: 'نوتيلا', price: 0.75),
    const AddonModel(id: 'a2', name: 'لوتس', price: 0.75),
    const AddonModel(id: 'a3', name: 'كراميل', price: 0.50),
    const AddonModel(id: 'a4', name: 'فراولة', price: 0.50),
    const AddonModel(id: 'a5', name: 'كريمة مخفوقة', price: 0.50),
    const AddonModel(id: 'a6', name: 'شوكولاتة', price: 0.75),
    const AddonModel(id: 'a7', name: 'بروتين', price: 1.00),
  ];

  // ══════════════════════════════════════════
  //  المنتجات
  // ══════════════════════════════════════════
  static final products = [
    // عصائر طبيعية
    ProductModel(
      id: 'p1', categoryId: 'cat1', name: 'عصير برتقال طبيعي',
      description: 'عصير برتقال طازج 100% طبيعي بدون سكر مضاف',
      priceS: 1.50, priceM: 2.00, priceL: 2.75,
      availableAddons: [addons[6]], isPopular: true,
    ),
    ProductModel(
      id: 'p2', categoryId: 'cat1', name: 'عصير ليمون بالنعناع',
      description: 'ليمون طازج مع أوراق نعناع منعشة',
      priceS: 1.25, priceM: 1.75, priceL: 2.50,
      availableAddons: [], isPopular: true,
    ),
    ProductModel(
      id: 'p3', categoryId: 'cat1', name: 'عصير رمان',
      description: 'عصير رمان طبيعي غني بمضادات الأكسدة',
      priceS: 2.00, priceM: 2.75, priceL: 3.50,
      availableAddons: [addons[6]],
    ),
    ProductModel(
      id: 'p4', categoryId: 'cat1', name: 'عصير جزر وبرتقال',
      description: 'مزيج صحي من الجزر والبرتقال الطازج',
      priceS: 1.75, priceM: 2.25, priceL: 3.00,
      availableAddons: [addons[6]],
    ),
    ProductModel(
      id: 'p5', categoryId: 'cat1', name: 'عصير تفاح أخضر',
      description: 'تفاح أخضر طازج منعش ومفيد',
      priceS: 1.50, priceM: 2.00, priceL: 2.75,
      availableAddons: [],
    ),

    // مكس شلمونة
    ProductModel(
      id: 'p6', categoryId: 'cat2', name: 'شلمونة سبيشل',
      description: 'خلطتنا السرية من الفواكه الاستوائية المميزة',
      priceS: 2.50, priceM: 3.25, priceL: 4.00,
      availableAddons: [addons[0], addons[1], addons[4], addons[5]],
      isPopular: true,
    ),
    ProductModel(
      id: 'p7', categoryId: 'cat2', name: 'مانجو باشن',
      description: 'مانجو طازج مع فاكهة الباشن فروت',
      priceS: 2.25, priceM: 3.00, priceL: 3.75,
      availableAddons: [addons[4], addons[5]],
      isPopular: true,
    ),
    ProductModel(
      id: 'p8', categoryId: 'cat2', name: 'بيري بلاست',
      description: 'مزيج من التوت والفراولة والبلوبيري',
      priceS: 2.50, priceM: 3.25, priceL: 4.00,
      availableAddons: [addons[0], addons[3], addons[4]],
    ),
    ProductModel(
      id: 'p9', categoryId: 'cat2', name: 'تروبيكال سموذي',
      description: 'أناناس وموز وجوز الهند الاستوائي',
      priceS: 2.75, priceM: 3.50, priceL: 4.25,
      availableAddons: [addons[4], addons[6]],
    ),

    // ساخن
    ProductModel(
      id: 'p10', categoryId: 'cat3', name: 'سحلب شلمونة',
      description: 'سحلب كريمي مع مكسرات وقرفة',
      priceS: 1.75, priceM: 2.25, priceL: 3.00,
      availableAddons: [addons[0], addons[1], addons[2]],
      isPopular: true,
    ),
    ProductModel(
      id: 'p11', categoryId: 'cat3', name: 'شوكولاتة ساخنة',
      description: 'شوكولاتة بلجيكية فاخرة ساخنة',
      priceS: 2.00, priceM: 2.75, priceL: 3.50,
      availableAddons: [addons[4], addons[0]],
    ),

    // حلى
    ProductModel(
      id: 'p12', categoryId: 'cat4', name: 'وافل شلمونة',
      description: 'وافل مقرمش مع صوص الشوكولاتة والفواكه',
      priceS: 2.50, priceM: 3.50, priceL: 4.50,
      availableAddons: [addons[0], addons[1], addons[3], addons[5]],
      isPopular: true,
    ),
    ProductModel(
      id: 'p13', categoryId: 'cat4', name: 'كنافة بالقشطة',
      description: 'كنافة ناعمة محشوة بالقشطة العربية',
      priceS: 2.00, priceM: 3.00, priceL: 4.00,
      availableAddons: [],
    ),
  ];

  /// المنتجات حسب التصنيف
  static List<ProductModel> productsByCategory(String categoryId) {
    return products.where((p) => p.categoryId == categoryId).toList();
  }

  /// المنتجات الشعبية
  static List<ProductModel> get popularProducts {
    return products.where((p) => p.isPopular).toList();
  }

  /// بحث في المنتجات
  static List<ProductModel> searchProducts(String query) {
    final q = query.toLowerCase();
    return products
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q))
        .toList();
  }
}
